# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.0] - 2025-06-21

### Added
- `parse_batch/2` function for processing multiple inputs efficiently
- `can_parse?/2` function to check parsing capability without retrieving results
- `stats/1` function to get comprehensive FST statistics (vertex count, edge count, terminal vertices)
- Comprehensive type specifications (@spec) for all public and private functions
- Enhanced test coverage with 14 comprehensive tests (up from 5 original tests)
- Edge case testing for empty strings, invalid inputs, and error conditions
- Code formatter configuration (`.formatter.exs`) for consistent code style
- Development dependencies: Credo, Dialyxir, mix_test_watch for improved development workflow
- Mix aliases for quality checks and continuous integration
- Detailed function documentation with clear return type specifications

### Changed
- **BREAKING**: Updated `parse/2` return type to be more explicit with tagged tuples:
  - `{:ok, result}` for successful single transduction
  - `{:ambiguous, [results]}` for multiple possible transductions
  - `{:error, reason}` for failed transductions
- Fixed typo: `{:ambigious, _}` → `{:ambiguous, _}`
- Modernized dependencies: 
  - `gen_state_machine` from ~> 2.0 to ~> 3.0
  - `libgraph` from ~> 0.9 to ~> 0.16
  - `ex_doc` from ~> 0.14 to ~> 0.30
- Updated configuration to use `Config` module instead of deprecated `Mix.Config`
- Enhanced project metadata in mix.exs with better descriptions and documentation links
- Improved error handling in `transduce/4` function to properly handle empty results
- Enhanced documentation with grouped functions and better examples

### Fixed
- Resolved unused variable warnings in `process_rule_item/5` function
- Fixed logic error in string slicing for transformation rules where `h_to` was incorrectly using `from` instead of `to`
- Corrected terminal state handling in complex transformation rules
- Fixed empty string parsing that was causing protocol errors
- Eliminated all compilation warnings in project code

### Internal
- Expanded test suite from 5 to 14 comprehensive tests
- Added ambiguous parsing tests and edge case coverage
- Improved code quality with better type annotations and documentation
- Enhanced development workflow with quality tools and continuous testing
- Added comprehensive demo script showcasing all functionality

## [0.4.1] - Previous Release
- Initial stable release with core FST functionality
- Basic morphological parsing capabilities
- Rule-based transduction system