# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.2] - 2024-12-19

### Added
- `parse_batch/2` function for processing multiple inputs at once
- `can_parse?/2` function to check if input can be parsed without getting the result
- `stats/1` function to get FST statistics (vertex count, edge count, etc.)
- Comprehensive type specifications for all public functions
- Additional test coverage for edge cases and new functionality
- Code formatter configuration
- Development dependencies (Credo, Dialyxir, test watcher)

### Changed
- Updated `parse/2` return type to be more explicit with tagged tuples
- Fixed typo: `{:ambigious, _}` → `{:ambiguous, _}`
- Modernized dependencies (gen_state_machine ~> 3.0, libgraph ~> 0.16)
- Updated configuration to use `Config` module instead of deprecated `Mix.Config`
- Improved documentation with better examples and explanations
- Enhanced project metadata in mix.exs

### Fixed
- Resolved unused variable warnings in `process_rule_item/5`
- Fixed logic error in string slicing for transformation rules
- Corrected terminal state handling in complex transformation rules

### Internal
- Added comprehensive test suite with edge cases
- Improved code quality with better type annotations
- Enhanced documentation with grouped functions

## [0.4.1] - Previous Release
- Initial stable release with core FST functionality