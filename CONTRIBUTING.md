# Contributing to SkyKraft

Thank you for your interest in contributing to SkyKraft! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### 1. Fork the Repository
- Fork the SkyKraft repository to your GitHub account
- Clone your fork locally: `git clone https://github.com/yourusername/SkyKraft.git`

### 2. Create a Feature Branch
- Create a new branch for your feature: `git checkout -b feature/YourFeatureName`
- Use descriptive branch names (e.g., `feature/user-authentication`, `bugfix/map-rendering`)

### 3. Make Your Changes
- Write clean, readable code
- Follow the existing code style and conventions
- Add comments for complex logic
- Update documentation if needed

### 4. Test Your Changes
- Run existing tests: `flutter test`
- Add new tests for new functionality
- Test on multiple platforms if possible

### 5. Commit Your Changes
- Use clear, descriptive commit messages
- Follow conventional commit format: `type(scope): description`
- Examples:
  - `feat(auth): add biometric authentication`
  - `fix(map): resolve marker positioning issue`
  - `docs(readme): update installation instructions`

### 6. Push and Create a Pull Request
- Push your branch: `git push origin feature/YourFeatureName`
- Create a pull request with a clear description
- Link any related issues

## 📋 Pull Request Guidelines

### Before Submitting
- [ ] Code follows project style guidelines
- [ ] All tests pass
- [ ] Documentation is updated
- [ ] No merge conflicts
- [ ] Code is self-reviewed

### Pull Request Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Refactoring

## Testing
- [ ] Unit tests added/updated
- [ ] Manual testing completed
- [ ] Cross-platform testing (if applicable)

## Screenshots (if UI changes)
Add screenshots here

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code where necessary
- [ ] I have made corresponding changes to documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective
```

## 🎨 Code Style Guidelines

### Dart/Flutter
- Follow Dart style guide: https://dart.dev/guides/language/effective-dart/style
- Use 2-space indentation
- Maximum line length: 80 characters
- Use meaningful variable and function names
- Add documentation comments for public APIs

### File Organization
- Keep files focused and single-purpose
- Use consistent naming conventions
- Group related functionality together
- Follow the existing project structure

### Naming Conventions
- **Files**: snake_case.dart
- **Classes**: PascalCase
- **Variables/Functions**: camelCase
- **Constants**: SCREAMING_SNAKE_CASE

## 🧪 Testing Guidelines

### Unit Tests
- Test all business logic
- Mock external dependencies
- Aim for high test coverage
- Use descriptive test names

### Widget Tests
- Test UI components
- Verify user interactions
- Test different states and configurations

### Integration Tests
- Test complete user workflows
- Verify app behavior end-to-end
- Test on real devices when possible

## 🐛 Bug Reports

### Before Reporting
- Check existing issues
- Search the documentation
- Try to reproduce the issue

### Bug Report Template
```markdown
## Bug Description
Clear description of the bug

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- OS: [e.g., iOS 16.0, Android 13]
- Device: [e.g., iPhone 14, Samsung Galaxy S23]
- Flutter Version: [e.g., 3.7.2]
- App Version: [e.g., 7.0.0]

## Additional Information
Screenshots, logs, or other relevant information
```

## 💡 Feature Requests

### Before Requesting
- Check if the feature already exists
- Consider the impact on existing functionality
- Think about implementation complexity

### Feature Request Template
```markdown
## Feature Description
Clear description of the requested feature

## Use Case
Why this feature is needed

## Proposed Implementation
How you think it could be implemented

## Alternatives Considered
Other approaches you've considered

## Additional Information
Any other relevant details
```

## 🔧 Development Setup

### Prerequisites
- Flutter SDK 3.7.2+
- Dart SDK 3.7.2+
- Android Studio / VS Code
- Git

### Local Development
1. Clone the repository
2. Install dependencies: `flutter pub get`
3. Configure Firebase and Mapbox
4. Run the app: `flutter run`

## 📚 Documentation

### Code Documentation
- Document all public APIs
- Use clear, concise language
- Include examples when helpful
- Keep documentation up-to-date

### README Updates
- Update README.md for new features
- Add screenshots for UI changes
- Update installation instructions
- Document configuration changes

## 🚀 Release Process

### Versioning
- Follow semantic versioning (MAJOR.MINOR.PATCH)
- Update version in `pubspec.yaml`
- Create release notes for significant changes

### Release Checklist
- [ ] All tests pass
- [ ] Documentation is updated
- [ ] Version numbers are updated
- [ ] Release notes are prepared
- [ ] Changelog is updated

## 🆘 Getting Help

### Questions and Discussions
- Use GitHub Discussions for questions
- Check existing documentation
- Search previous issues and discussions

### Contact
- Create an issue for bugs or feature requests
- Use discussions for questions and ideas
- Tag maintainers for urgent issues

## 📜 License

By contributing to SkyKraft, you agree that your contributions will be licensed under the MIT License.

## 🙏 Recognition

Contributors will be recognized in:
- Project README
- Release notes
- Contributor statistics
- Special acknowledgments for significant contributions

---

Thank you for contributing to SkyKraft! Your contributions help make this project better for everyone. 🚁✨
