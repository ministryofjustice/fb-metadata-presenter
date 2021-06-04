# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

### Changed

### Fixed

## [1.3.0] - 2021-06-04

### Changed

- Now the gem contains the upload behaviour logic in answers controller.

## [1.2.1] - 2021-06-03

### Fixed

- Pass component id to remove user data

## [1.2.0] - 2021-06-03

### Added

- Add ability to remove a previously uploaded file from user answers

## [1.1.1] - 2021-06-02

### Added

- Add the allowed file types to the upload component default metadata

## [1.1.0] - 2021-06-01

### Added

- Added file upload compononent and templates

## [1.0.8] - 2021-05-04

### Changed

- Use Ruby 2.7.3

## [1.0.7] - 2021-05-04

### Changed

- Remove section break from footer

## [1.0.6] - 2021-04-30

### Changed

- Remove section heading from start pages

## [1.0.5] - 2021-04-30

### Fixed

- UUIDs in fixture version should be unique so

## [1.0.4] - 2021-04-29

### Added

- Single question pages can also have optional section headings

## [1.0.3] - 2021-04-27

### Changed

- Default content text for collection component changed to be just "Option"

## [1.0.2] - 2021-04-26

### Fixed

- Removed `/` from the URLs of standalone pages in test fixtures

## [1.0.1] - 2021-04-22

### Fixed

- Removed optional hint text from collections in the test fixtures as they should not be there

## [1.0.0] - 2021-04-21

Initial version 1 release of the Metadata Presenter for use in the MVP of the Editor. It includes:

- JSON schemas for representing form metadata across MoJ Forms
- Default Metadata used by the Editor when creating new pages and components
- Default Text used by the Editor for optional text elements
- Templates for different page types
- Templates for different component types
- Logic for handling user answers in the Runner
- Logic relating to visible components and elements dependent upon whether the Presenter is in use in the Editor or the Runner
- Metadata validation
- Test fixtures showing examples of metadata created by the Editor
- Test helpers
