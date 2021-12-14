# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
### Added
### Changed
### Fixed

## [2.12.0] - 2021-12-08

### Changed

- Add possibility to accept apostrophe in service names

## [2.11.0] - 2021-12-08

### Changed

- Make space for branch expressions if more than one branch occupy the same column

## [2.10.0] - 2021-12-02

### Changed

- Change grid model to only skip traversing a route if it has already done so

## [2.9.0] - 2021-10-21

### Changed

- Updated all fixtures to reflect the conditionals uuids

## [2.8.0] - 2021-10-20

### Changed

- Add UUID to conditional objects in a branch

## [2.7.2] - 2021-10-08

### Fixed

- Make sure the grid for a service flow is at least a 1 x 1
- Remove any columns that only contain Spacer objects

### Changed

- Grid model can now start creating flows from any object but defaults to the start page

### Added

- Use Pointer objects to reference any object that exists in the main service flow
- Surface flow UUIDs and page UUIDs that any grid object has interacted with

## [2.7.1] - 2021-10-08

### Added

- Add methods to check if the page is the last page in a route.
- This helps determine whether we allow adding of pages or branches,
or changes of destination from these pages.

## [2.7.0] - 2021-10-07

### Added

- Add MetadataPresenter::Service#conditionals that returns *all* conditionals
in the metadata
- Add MetadataPresenter::Service#expressions that returns *all* expressions

## [2.6.2] - 2021-10-05

### Added

- Add exit only fixture

## [2.6.1] - 2021-10-05

### Fixed

- Ensure the correct titles are used for exit pages

## [2.6.0] - 2021-10-01

### Added

- Exit page schemas and default metadata

## [2.5.1] - 2021-09-28

### Changed

- Do not build the ordered flow twice

### Fixed

-  Update the Branching fixture names for 7 and 8

## [2.5.0] - 2021-09-28

### Added

- Added the Route and Grid models to figure out the row and column layout for a service flow

## [2.4.2] - 2021-09-27

### Added

- Added all_destination_uuids method to Flow object
- Added an additional 7 branching fixtures of varying flows

### Changed

- Stop pinning rubocop

## [2.4.1] - 2021-09-09

### Changed

- Use multiplequestions page title even when there is only one component

## [2.4.0] - 2021-09-07

### Added

- Add change your answers feature

### Changed

## [2.3.6] - 2021-09-01

### Changed

- Fix 'Before you start' section on Start page so the content is editable and retrievable.

## [2.3.5] - 2021-08-31

### Changed

- Fix spacing on 'Check your answers' page

## [2.3.4] - 2021-08-24

### Changed

- Memoize the Page and Component inside Expression objects

## [2.3.3] - 2021-08-20

### Added

- Added titles to the branch objects in the fixtures

## [2.3.2] - 2021-08-18

### Changed

- Remove lede from the start page metadata

## [2.3.1] - 2021-08-16

### Added

- Add flow_objects method to the service which returns all the service flow as MetadataPresenter::Flow objects

### Changed

- Surface the page uuid for the related flow object

## [2.3.0] - 2021-08-09

### Added

- Return all branches from a service

## [2.2.0] - 2021-08-05

### Changed

- The methods in the page model relating to input and content components were not actually returning those objects.
  They actually relate to supported components for a given page. Change the method names to better describe that
- Add input_components and content_components methods which actually return objects of those types

### Added

- Add question_page? method on the page model. Should only be true for single question and multiple questions pages

## [2.1.0] - 2021-07-27

### Added

- Added method to the service which returns a page object containing a given component uuid

## [2.1.0] - 2021-07-27

### Changed

- Remove back links from standalone pages

## [2.0.2] - 2021-07-26

### Changed

- Use service flow objects exclusively
- Update all fixtures to use service flow

## [2.0.1] - 2021-07-23

### Added

- Add title method to page to return the question, heading or component legend or label
- Begin to support branching with radio and checkbox components

## [2.0.0] - 2021-07-13

### Changed

- Breaking change
- Use conditionals and expressions as the properties for branching objects and logic

## [1.9.0] - 2021-07-09

### Added

- Make sure traversed pages can be used in the submissions

## [1.8.1] - 2021-07-09

### Added

- Added service and version fixtures for additional testing

## [1.8.0] - 2021-07-08

### Added

- Display answers on the check your answers page based on branching.

## [1.7.5] - 2021-07-08

### Added

- Base flow object schema to cater for dynamic UUID properties

### Changed

- Remove '_id' property from flow objects default metadata
- Fallback to using '_type' as the key for default metadata that does not have a '_id' property

## [1.7.4] - 2021-07-08

### Added

- Schemas and default metadata for all flow objects

## [1.7.3] - 2021-07-07

### Changed

- Calling flow on a service should now return all of the flow objects

## [1.7.2] - 2021-07-07

### Added

- Added more pages to the branching fixture for checkboxes multiple conditions
using "AND" / "OR".

### Changed

- Change the generates the flow diagrams for multiple conditions.

## [1.7.1] - 2021-07-06

### Added

- Add sanitise JavaScript so malicious code is not saved in the database

## [1.7.0] - 2021-07-05

### Added

- Add multiple conditions (OR / AND) on multiple criterias for same condition

## [1.6.1] - 2021-07-01

### Fix

- Do not require ruby graphviz in runtime, only when you run the diagram rake
    task

## [1.6.0] - 2021-07-01

### Added

- Simple branching back links

## [1.5.0] - 2021-06-28

### Added

- Simple branching (single conditions) with checkboxes

## [1.4.0] - 2021-06-24

### Added

- Simple branching (single conditions) with radio buttons

## [1.3.2] - 2021-06-11

- Add open office spreadsheet to upload component default metadata

### Added

### Fixed

## [1.3.1] - 2021-06-04

### Fixed

- Return and empty file object when there is no file to be uploaded

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
