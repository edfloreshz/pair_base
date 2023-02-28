String? validateNumber(value) => value!.isEmpty
    ? "Value cannot be empty"
    : int.tryParse(value) == null
        ? "Value must be a number"
        : null;

String? validateEmpty(value) => value!.isEmpty ? "Value cannot be empty" : null;

String? validateKey(key, root) => key!.isEmpty
    ? "Key cannot be empty"
    : root is List
        ? root.where((element) => (element == key)).isNotEmpty
            ? "Key already exists"
            : null
        : root.containsKey(key)
            ? "Key already exists"
            : null;
