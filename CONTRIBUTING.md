# Contributing to LIVE-BOOT

Thank you for your interest in contributing to LIVE-BOOT! This document provides guidelines and instructions for contributing.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [How Can I Contribute?](#how-can-i-contribute)
3. [Development Setup](#development-setup)
4. [Coding Standards](#coding-standards)
5. [Commit Guidelines](#commit-guidelines)
6. [Pull Request Process](#pull-request-process)
7. [Testing](#testing)
8. [Documentation](#documentation)

## Code of Conduct

This project adheres to a code of conduct that all contributors are expected to follow:

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive feedback
- Accept responsibility and apologize when mistakes are made
- Focus on what is best for the community

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates.

When creating a bug report, include:

- **Clear title** - Descriptive and specific
- **Description** - Detailed description of the issue
- **Steps to reproduce** - Clear steps to reproduce the problem
- **Expected behavior** - What you expected to happen
- **Actual behavior** - What actually happened
- **Environment** - OS, version, hardware details
- **Logs** - Relevant error messages or logs
- **Screenshots** - If applicable

**Example:**
```
Title: USB boot creation fails on Ubuntu 22.04

Description:
When attempting to create a bootable USB drive, the script fails
with permission denied error.

Steps to reproduce:
1. Run `sudo ./live-boot-installer.sh`
2. Select option 1
3. Choose device /dev/sdb
4. Select ISO file

Expected: USB drive is created successfully
Actual: Error "Permission denied" at partition creation step

Environment:
- OS: Ubuntu 22.04.3 LTS
- Script version: 1.0.0
- Hardware: HP EliteBook 840 G8

Logs:
[ERROR] Permission denied: /dev/sdb
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title** - Descriptive feature name
- **Use case** - Why this enhancement would be useful
- **Proposed solution** - How you envision it working
- **Alternatives** - Other solutions you've considered
- **Additional context** - Screenshots, mockups, etc.

### Contributing Code

#### First-time Contributors

Look for issues labeled:
- `good first issue` - Suitable for newcomers
- `help wanted` - Extra attention needed
- `documentation` - Documentation improvements

#### Areas to Contribute

- **New features** - Additional boot methods, OS support
- **Bug fixes** - Resolve existing issues
- **Documentation** - Improve guides and examples
- **Testing** - Add test coverage
- **Translations** - Localization support
- **Performance** - Optimization improvements

## Development Setup

### Prerequisites

```bash
# Install git
sudo apt install git  # Debian/Ubuntu
sudo dnf install git  # Fedora

# Install required tools
sudo apt install shellcheck  # Shell script linter
```

### Fork and Clone

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/LIVE-BOOT.git
cd LIVE-BOOT

# Add upstream remote
git remote add upstream https://github.com/acesonder/LIVE-BOOT.git
```

### Create Branch

```bash
# Update your fork
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

## Coding Standards

### Shell Script Guidelines

- **Shebang**: Always use `#!/bin/bash`
- **Error handling**: Use `set -e` when appropriate
- **Functions**: Use functions for reusable code
- **Comments**: Comment complex logic
- **Variables**: Use descriptive names
- **Quotes**: Quote variables: `"$variable"`
- **Exit codes**: Return appropriate exit codes

### Style Guide

```bash
# Good variable names
user_choice=""
target_device="/dev/sdb"
iso_file_path=""

# Use functions
create_partition() {
    local device="$1"
    # Function logic
}

# Error handling
if [[ ! -f "$file" ]]; then
    error "File not found: $file"
    return 1
fi

# Use color codes consistently
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}
```

### Linting

Run shellcheck before committing:

```bash
# Check all scripts
shellcheck live-boot-installer.sh
shellcheck scripts/*.sh

# Fix common issues automatically
shellcheck -f diff script.sh | patch
```

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**

```
feat(usb): Add support for exFAT filesystem

- Add exFAT formatting option
- Update menu to include exFAT choice
- Add dependency check for exfat-utils

Closes #42
```

```
fix(network): Resolve PXE boot timeout issue

The PXE server wasn't responding due to incorrect
dnsmasq configuration. Updated configuration template
to fix DHCP range overlap.

Fixes #38
```

```
docs(readme): Update quick start instructions

- Clarify prerequisites
- Add HP boot key reference
- Include troubleshooting tips
```

### Commit Best Practices

- One logical change per commit
- Write clear, concise messages
- Reference issues when applicable
- Keep commits atomic and reversible

## Pull Request Process

### Before Submitting

1. **Update your branch**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Test your changes**
   - Test on target systems
   - Verify no regressions
   - Check edge cases

3. **Lint your code**
   ```bash
   shellcheck scripts/*.sh
   ```

4. **Update documentation**
   - Update README if needed
   - Add to CHANGELOG.md
   - Update relevant docs

### Submitting Pull Request

1. **Push your branch**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create PR on GitHub**
   - Go to repository on GitHub
   - Click "New Pull Request"
   - Select your branch
   - Fill out PR template

3. **PR Title Format**
   ```
   [Type] Brief description
   ```
   Example: `[Feature] Add Arch Linux support`

4. **PR Description Include**
   - What changes were made
   - Why changes were made
   - Testing performed
   - Related issues
   - Screenshots (if UI changes)

### PR Template

```markdown
## Description
Brief description of changes

## Motivation
Why are these changes needed?

## Changes Made
- Change 1
- Change 2
- Change 3

## Testing
- [ ] Tested on Ubuntu 22.04
- [ ] Tested on Fedora 38
- [ ] Tested with USB boot
- [ ] Tested with network boot

## Related Issues
Closes #XX
Related to #YY

## Screenshots
(If applicable)

## Checklist
- [ ] Code follows project style
- [ ] Commits are atomic
- [ ] Documentation updated
- [ ] CHANGELOG updated
- [ ] Tested on target systems
- [ ] No breaking changes
```

### Review Process

1. Maintainers will review your PR
2. Feedback will be provided if changes needed
3. Make requested changes
4. Push updates to same branch
5. PR will be merged when approved

### After Merge

```bash
# Update your local main
git checkout main
git pull upstream main

# Delete feature branch
git branch -d feature/your-feature-name
git push origin --delete feature/your-feature-name
```

## Testing

### Manual Testing

Test your changes on:

- [ ] Different Linux distributions (Ubuntu, Fedora, Debian)
- [ ] Different HP laptop models (if possible)
- [ ] UEFI and Legacy boot modes
- [ ] Various storage device types (USB, SD, HDD)
- [ ] Different ISO sizes and distributions

### Test Checklist

For feature additions:
- [ ] Feature works as intended
- [ ] Error handling is appropriate
- [ ] Help text is clear
- [ ] Works with existing features
- [ ] No regressions introduced

For bug fixes:
- [ ] Bug is actually fixed
- [ ] Fix doesn't break other features
- [ ] Similar bugs are addressed
- [ ] Root cause is documented

## Documentation

### Documentation Standards

- **Clear and concise** - Easy to understand
- **Well-organized** - Logical structure
- **Examples** - Include practical examples
- **Updated** - Keep in sync with code
- **Formatted** - Use proper markdown

### Documentation Types

1. **Code Comments**
   ```bash
   # Brief description of what function does
   function_name() {
       # Explain complex logic
       complex_operation
   }
   ```

2. **README Updates**
   - Keep main README current
   - Update feature lists
   - Add new examples

3. **Guide Updates**
   - Update relevant guides
   - Add troubleshooting steps
   - Include new scenarios

4. **CHANGELOG**
   - Document all changes
   - Follow format consistently
   - Credit contributors

### Writing Style

- Use active voice
- Be specific and concrete
- Include examples
- Explain "why" not just "how"
- Consider different user levels

## Questions?

If you have questions:

1. Check existing documentation
2. Search closed issues
3. Ask in discussions
4. Open an issue with `question` label

## Recognition

Contributors will be recognized in:
- CHANGELOG.md
- Project README
- Release notes

Thank you for contributing to LIVE-BOOT! 🎉

---

*This contributing guide is subject to change. Check back regularly for updates.*
