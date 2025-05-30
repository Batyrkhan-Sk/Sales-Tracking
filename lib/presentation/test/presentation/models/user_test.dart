import 'package:flutter_test/flutter_test.dart';
import '../../../../presentation/models/user.dart';

void main() {
  group('User Model', () {
    group('Constructor', () {
      test('should create User with required fields', () {
        final user = User(
          fullName: 'John Doe',
          email: 'john.doe@example.com',
        );

        expect(user.fullName, equals('John Doe'));
        expect(user.email, equals('john.doe@example.com'));
        expect(user.id, isNull);
        expect(user.password, isNull);
        expect(user.role, equals(''));
      });

      test('should create User with all fields', () {
        // Arrange & Act
        final user = User(
          id: '123',
          fullName: 'Jane Smith',
          email: 'jane.smith@example.com',
          password: 'password123',
          role: 'admin',
        );

        expect(user.id, equals('123'));
        expect(user.fullName, equals('Jane Smith'));
        expect(user.email, equals('jane.smith@example.com'));
        expect(user.password, equals('password123'));
        expect(user.role, equals('admin'));
      });

      test('should set default empty role when not provided', () {
        final user = User(
          fullName: 'Test User',
          email: 'test@example.com',
        );

        expect(user.role, equals(''));
      });
    });

    group('fromJson', () {
      test('should create User from JSON with all fields', () {
        final json = {
          'id': '456',
          'fullName': 'Alice Johnson',
          'email': 'alice@example.com',
          'role': 'user',
        };

        final user = User.fromJson(json);

        expect(user.id, equals('456'));
        expect(user.fullName, equals('Alice Johnson'));
        expect(user.email, equals('alice@example.com'));
        expect(user.role, equals('user'));
      });

      test('should create User from JSON with _id field', () {
        // Arrange
        final json = {
          '_id': '789',
          'fullName': 'Bob Wilson',
          'email': 'bob@example.com',
          'role': 'moderator',
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.id, equals('789'));
        expect(user.fullName, equals('Bob Wilson'));
        expect(user.email, equals('bob@example.com'));
        expect(user.role, equals('moderator'));
      });

      test('should prefer id over _id when both are present', () {
        // Arrange
        final json = {
          'id': '123',
          '_id': '456',
          'fullName': 'Test User',
          'email': 'test@example.com',
          'role': 'user',
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.id, equals('123')); // Should use 'id', not '_id'
      });

      test('should handle missing fields with default values', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.id, isNull);
        expect(user.fullName, equals(''));
        expect(user.email, equals(''));
        expect(user.role, equals(''));
      });

      test('should handle null values in JSON', () {
        // Arrange
        final json = {
          'id': null,
          'fullName': null,
          'email': null,
          'role': null,
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.id, isNull);
        expect(user.fullName, equals(''));
        expect(user.email, equals(''));
        expect(user.role, equals(''));
      });
    });

    group('toJson', () {
      test('should convert User to JSON with all fields', () {
        // Arrange
        final user = User(
          id: '123',
          fullName: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
          role: 'admin',
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json, equals({
          'id': '123',
          'fullName': 'John Doe',
          'email': 'john@example.com',
          'password': 'password123',
          'role': 'admin',
        }));
      });

      test('should exclude null id from JSON', () {
        // Arrange
        final user = User(
          fullName: 'Jane Smith',
          email: 'jane@example.com',
          role: 'user',
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json, equals({
          'fullName': 'Jane Smith',
          'email': 'jane@example.com',
          'role': 'user',
        }));
        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('password'), isFalse);
      });

      test('should exclude null password from JSON', () {
        // Arrange
        final user = User(
          id: '456',
          fullName: 'Test User',
          email: 'test@example.com',
          role: 'user',
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json, equals({
          'id': '456',
          'fullName': 'Test User',
          'email': 'test@example.com',
          'role': 'user',
        }));
        expect(json.containsKey('password'), isFalse);
      });

      test('should exclude empty role from JSON', () {
        // Arrange
        final user = User(
          id: '789',
          fullName: 'Empty Role User',
          email: 'empty@example.com',
          role: '', // Empty role
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json, equals({
          'id': '789',
          'fullName': 'Empty Role User',
          'email': 'empty@example.com',
        }));
        expect(json.containsKey('role'), isFalse);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        // Arrange
        final originalUser = User(
          id: '123',
          fullName: 'John Doe',
          email: 'john@example.com',
          password: 'oldPassword',
          role: 'user',
        );

        // Act
        final updatedUser = originalUser.copyWith(
          fullName: 'John Smith',
          role: 'admin',
        );

        // Assert
        expect(updatedUser.id, equals('123')); // Unchanged
        expect(updatedUser.fullName, equals('John Smith')); // Updated
        expect(updatedUser.email, equals('john@example.com')); // Unchanged
        expect(updatedUser.password, equals('oldPassword')); // Unchanged
        expect(updatedUser.role, equals('admin')); // Updated
      });

      test('should create copy with all fields updated', () {
        // Arrange
        final originalUser = User(
          id: '123',
          fullName: 'John Doe',
          email: 'john@example.com',
          password: 'oldPassword',
          role: 'user',
        );

        // Act
        final updatedUser = originalUser.copyWith(
          id: '456',
          fullName: 'Jane Smith',
          email: 'jane@example.com',
          password: 'newPassword',
          role: 'admin',
        );

        // Assert
        expect(updatedUser.id, equals('456'));
        expect(updatedUser.fullName, equals('Jane Smith'));
        expect(updatedUser.email, equals('jane@example.com'));
        expect(updatedUser.password, equals('newPassword'));
        expect(updatedUser.role, equals('admin'));
      });

      test('should create identical copy when no parameters provided', () {
        // Arrange
        final originalUser = User(
          id: '123',
          fullName: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
          role: 'user',
        );

        // Act
        final copiedUser = originalUser.copyWith();

        // Assert
        expect(copiedUser.id, equals(originalUser.id));
        expect(copiedUser.fullName, equals(originalUser.fullName));
        expect(copiedUser.email, equals(originalUser.email));
        expect(copiedUser.password, equals(originalUser.password));
        expect(copiedUser.role, equals(originalUser.role));

        // Ensure they are different instances
        expect(identical(originalUser, copiedUser), isFalse);
      });

      test('should preserve original values when copyWith parameters are not provided', () {
        // Arrange
        final originalUser = User(
          id: '123',
          fullName: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
          role: 'user',
        );

        // Act - Not passing any parameters should preserve all values
        final updatedUser = originalUser.copyWith();

        // Assert
        expect(updatedUser.id, equals('123')); // Preserved
        expect(updatedUser.fullName, equals('John Doe')); // Preserved
        expect(updatedUser.email, equals('john@example.com')); // Preserved
        expect(updatedUser.password, equals('password123')); // Preserved
        expect(updatedUser.role, equals('user')); // Preserved
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        // Arrange
        final user = User(
          id: '123',
          fullName: 'John Doe',
          email: 'john@example.com',
          role: 'admin',
        );

        // Act
        final result = user.toString();

        // Assert
        expect(result, equals('User(id: 123, name: John Doe, email: john@example.com, role: admin)'));
      });

      test('should handle null id in toString', () {
        // Arrange
        final user = User(
          fullName: 'Jane Smith',
          email: 'jane@example.com',
          role: 'user',
        );

        // Act
        final result = user.toString();

        // Assert
        expect(result, equals('User(id: null, name: Jane Smith, email: jane@example.com, role: user)'));
      });

      test('should handle empty role in toString', () {
        // Arrange
        final user = User(
          id: '456',
          fullName: 'Test User',
          email: 'test@example.com',
        );

        // Act
        final result = user.toString();

        // Assert
        expect(result, equals('User(id: 456, name: Test User, email: test@example.com, role: )'));
      });
    });

    group('Edge Cases', () {
      test('should handle JSON serialization round trip', () {
        // Arrange
        final originalUser = User(
          id: '123',
          fullName: 'Round Trip Test',
          email: 'roundtrip@example.com',
          role: 'tester',
        );

        // Act
        final json = originalUser.toJson();
        final reconstructedUser = User.fromJson(json);

        // Assert
        expect(reconstructedUser.id, equals(originalUser.id));
        expect(reconstructedUser.fullName, equals(originalUser.fullName));
        expect(reconstructedUser.email, equals(originalUser.email));
        expect(reconstructedUser.role, equals(originalUser.role));
        expect(reconstructedUser.password, equals(originalUser.password));
      });

      test('should handle empty strings in all fields', () {
        // Arrange & Act
        final user = User(
          id: '',
          fullName: '',
          email: '',
          password: '',
          role: '',
        );

        // Assert
        expect(user.id, equals(''));
        expect(user.fullName, equals(''));
        expect(user.email, equals(''));
        expect(user.password, equals(''));
        expect(user.role, equals(''));
      });
    });
  });
}