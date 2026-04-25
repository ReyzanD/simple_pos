import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:simple_pos/features/inventory/domain/entities/product.dart';
import 'package:simple_pos/features/inventory/domain/repositories/product_repository.dart';
import 'package:simple_pos/features/pos/domain/entities/cart_item.dart';
import 'package:simple_pos/features/pos/domain/usecases/checkout_usecase.dart';
import 'package:simple_pos/features/sales/domain/usecases/create_transaction_usecase.dart';
import 'package:simple_pos/features/sales/domain/entities/payment_method.dart';

// Generate mocks
@GenerateMocks([ProductRepository, CreateTransactionUseCase])
import 'checkout_usecase_test.mocks.dart';

void main() {
  late CheckoutUseCase useCase;
  late MockProductRepository mockRepository;
  late MockCreateTransactionUseCase mockCreateTransactionUseCase;

  setUp(() {
    mockRepository = MockProductRepository();
    mockCreateTransactionUseCase = MockCreateTransactionUseCase();
    useCase = CheckoutUseCase(
      productRepository: mockRepository,
      createTransactionUseCase: mockCreateTransactionUseCase,
    );
  });

  group('CheckoutUseCase', () {
    late Product testProduct1;
    late Product testProduct2;
    late List<CartItem> testCart;
    late dynamic mockTransaction;

    setUp(() {
      testProduct1 = Product(
        id: 1,
        name: 'Product 1',
        price: 100.0,
        stock: 10,
      );
      testProduct2 = Product(
        id: 2,
        name: 'Product 2',
        price: 200.0,
        stock: 20,
      );
      testCart = [
        CartItem(product: testProduct1, quantity: 2),
        CartItem(product: testProduct2, quantity: 3),
      ];
      mockTransaction = {'id': 1};
    });

    test('should process checkout successfully', () async {
      // Arrange
      when(mockCreateTransactionUseCase.execute(
        cart: anyNamed('cart'),
        paymentMethod: anyNamed('paymentMethod'),
        cashReceived: anyNamed('cashReceived'),
        cardLast4Digits: anyNamed('cardLast4Digits'),
        notes: anyNamed('notes'),
        tax: anyNamed('tax'),
        discount: anyNamed('discount'),
      )).thenAnswer((_) async => mockTransaction);

      // Act
      final result = await useCase.execute(
        cart: testCart,
        paymentMethod: PaymentMethod.cash,
      );

      // Assert
      expect(result.success, true);
      expect(result.itemsProcessed, 2);
      verify(mockCreateTransactionUseCase.execute(
        cart: testCart,
        paymentMethod: PaymentMethod.cash,
        cashReceived: null,
        cardLast4Digits: null,
        notes: null,
        tax: 0,
        discount: 0,
      )).called(1);
    });

    test('should return failure when cart is empty', () async {
      // Arrange
      final emptyCart = <CartItem>[];

      // Act
      final result = await useCase.execute(
        cart: emptyCart,
        paymentMethod: PaymentMethod.cash,
      );

      // Assert
      expect(result.success, false);
      expect(result.message, contains('Keranjang kosong'));
      verifyNever(mockCreateTransactionUseCase.execute(
        cart: anyNamed('cart'),
        paymentMethod: anyNamed('paymentMethod'),
        cashReceived: anyNamed('cashReceived'),
        cardLast4Digits: anyNamed('cardLast4Digits'),
        notes: anyNamed('notes'),
        tax: anyNamed('tax'),
        discount: anyNamed('discount'),
      ));
    });

    test('should handle single item checkout', () async {
      // Arrange
      final cart = [
        CartItem(product: testProduct1, quantity: 5),
      ];
      when(mockCreateTransactionUseCase.execute(
        cart: anyNamed('cart'),
        paymentMethod: anyNamed('paymentMethod'),
        cashReceived: anyNamed('cashReceived'),
        cardLast4Digits: anyNamed('cardLast4Digits'),
        notes: anyNamed('notes'),
        tax: anyNamed('tax'),
        discount: anyNamed('discount'),
      )).thenAnswer((_) async => mockTransaction);

      // Act
      final result = await useCase.execute(
        cart: cart,
        paymentMethod: PaymentMethod.cash,
      );

      // Assert
      expect(result.success, true);
      expect(result.itemsProcessed, 1);
    });

    test('should handle checkout with tax and discount', () async {
      // Arrange
      when(mockCreateTransactionUseCase.execute(
        cart: anyNamed('cart'),
        paymentMethod: anyNamed('paymentMethod'),
        cashReceived: anyNamed('cashReceived'),
        cardLast4Digits: anyNamed('cardLast4Digits'),
        notes: anyNamed('notes'),
        tax: anyNamed('tax'),
        discount: anyNamed('discount'),
      )).thenAnswer((_) async => mockTransaction);

      // Act
      final result = await useCase.execute(
        cart: testCart,
        paymentMethod: PaymentMethod.cash,
        tax: 50,
        discount: 20,
      );

      // Assert
      expect(result.success, true);
      expect(result.totalAmount, 730); // (100*2 + 200*3) + 50 - 20 = 800 + 50 - 20 = 830
      verify(mockCreateTransactionUseCase.execute(
        cart: testCart,
        paymentMethod: PaymentMethod.cash,
        cashReceived: null,
        cardLast4Digits: null,
        notes: null,
        tax: 50,
        discount: 20,
      )).called(1);
    });

    test('should handle cash payment', () async {
      // Arrange
      when(mockCreateTransactionUseCase.execute(
        cart: anyNamed('cart'),
        paymentMethod: anyNamed('paymentMethod'),
        cashReceived: anyNamed('cashReceived'),
        cardLast4Digits: anyNamed('cardLast4Digits'),
        notes: anyNamed('notes'),
        tax: anyNamed('tax'),
        discount: anyNamed('discount'),
      )).thenAnswer((_) async => mockTransaction);

      // Act
      final result = await useCase.execute(
        cart: testCart,
        paymentMethod: PaymentMethod.cash,
        cashReceived: 1000,
      );

      // Assert
      expect(result.success, true);
      verify(mockCreateTransactionUseCase.execute(
        cart: testCart,
        paymentMethod: PaymentMethod.cash,
        cashReceived: 1000,
        cardLast4Digits: null,
        notes: null,
        tax: 0,
        discount: 0,
      )).called(1);
    });

    test('should handle card payment', () async {
      // Arrange
      when(mockCreateTransactionUseCase.execute(
        cart: anyNamed('cart'),
        paymentMethod: anyNamed('paymentMethod'),
        cashReceived: anyNamed('cashReceived'),
        cardLast4Digits: anyNamed('cardLast4Digits'),
        notes: anyNamed('notes'),
        tax: anyNamed('tax'),
        discount: anyNamed('discount'),
      )).thenAnswer((_) async => mockTransaction);

      // Act
      final result = await useCase.execute(
        cart: testCart,
        paymentMethod: PaymentMethod.card,
        cardLast4Digits: '1234',
      );

      // Assert
      expect(result.success, true);
      verify(mockCreateTransactionUseCase.execute(
        cart: testCart,
        paymentMethod: PaymentMethod.card,
        cashReceived: null,
        cardLast4Digits: '1234',
        notes: null,
        tax: 0,
        discount: 0,
      )).called(1);
    });

    test('should handle executeWithCashPayment', () async {
      // Arrange
      when(mockCreateTransactionUseCase.execute(
        cart: anyNamed('cart'),
        paymentMethod: anyNamed('paymentMethod'),
        cashReceived: anyNamed('cashReceived'),
        cardLast4Digits: anyNamed('cardLast4Digits'),
        notes: anyNamed('notes'),
        tax: anyNamed('tax'),
        discount: anyNamed('discount'),
      )).thenAnswer((_) async => mockTransaction);

      // Act
      final result = await useCase.executeWithCashPayment(
        cart: testCart,
        tax: 50,
        discount: 20,
      );

      // Assert
      expect(result.success, true);
      verify(mockCreateTransactionUseCase.execute(
        cart: testCart,
        paymentMethod: PaymentMethod.cash,
        cashReceived: 830,
        cardLast4Digits: null,
        notes: null,
        tax: 50,
        discount: 20,
      )).called(1);
    });
  });
}
