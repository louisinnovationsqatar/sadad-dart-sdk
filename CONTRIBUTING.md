# Contributing to sadad-dart-sdk

Thank you for your interest in contributing to this project!

## How to Contribute

### Reporting Issues

Before reporting an issue, please check if it already exists in the issue tracker. When reporting a bug, use the provided bug report template and include as much detail as possible.

### Submitting Changes

1. **Fork** the repository on GitHub
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/your-username/sadad-dart-sdk.git
   cd sadad-dart-sdk
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/my-new-feature
   ```
   Use descriptive branch names such as `feature/add-recurring-payments` or `fix/signature-validation-bug`.

4. **Install dependencies**:
   ```bash
   dart pub get
   ```

5. **Make your changes** following the existing code style and conventions.

6. **Write tests** for your changes. All new functionality must include unit tests.

7. **Run the test suite** and ensure all tests pass:
   ```bash
   dart test
   ```

8. **Run the analyzer** to check for issues:
   ```bash
   dart analyze
   ```

9. **Format your code**:
   ```bash
   dart format .
   ```

10. **Commit your changes** with a clear, descriptive commit message:
    ```bash
    git commit -m "Add support for recurring invoice payments"
    ```

11. **Push** to your fork:
    ```bash
    git push origin feature/my-new-feature
    ```

12. **Open a Pull Request** against the `main` branch with a clear title and description.

## Code Standards

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use Dart 3.0+ features (records, patterns, switch expressions) where appropriate
- Write clear, self-documenting code with doc comments (`///`) for all public APIs
- Keep methods focused and single-purpose
- Handle exceptions gracefully using the provided exception hierarchy

## Testing

All contributions must include appropriate test coverage. Tests live in the `test/` directory.

Run tests with:
```bash
dart test
```

## Questions

If you have questions or need clarification, feel free to reach out at info@louis-innovations.com.
