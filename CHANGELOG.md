# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
### Added
### Changed
### Fixed

## [3.2.3] - 2023-08-07
 - Update header logo to link to GOV.UK in response to accessibility audit

## [3.2.2] - 2023-08-03
### Added
- Updated test app default config to 7.0, deleted settings initialiser. Just part of cleanup after upgrading everything to rails 7.

## [3.2.1] - 2023-07-28
### Added
- Add logic to evaluate the content conditionals
- Content components will always show if no conditionals are present or if in the editor preview mode

## [3.2.0] - 2023-07-25
### Added
 - Update content component schema to accept conditionals and expressions
 - Update content page and check answers page schemas to remove 'body' attribute as we can not make this attribute conditional
 - Show 'body' HTML on content or check answers page only if it has been modified

## [3.1.0] - 2023-07-24
### Added
 - Multifile upload component release

## [3.0.15] - 2023-07-10
### Added
 - Added helper to answers controller to prevent error when validating

## [3.0.14] - 2023-07-10
### Added
 - Disable save and return on file upload components

## [3.0.13] - 2023-07-10
### Added
 - Makes the notification banners on standalone pages only display if the page
     still requires edits

## [3.0.12] - 2023-07-06
### Fixed
 - Fixed an issue where save and return would 404 if using a custom check your answers page.

## [3.0.11] - 2023-07-03
### Added
 - Added notification banners to accessibility and privacy standalone pages.

## [3.0.10] - 2023-06-30
### Added
 - Added nonces to the GA scripts for CSP violations.

## [3.0.9] - 2023-06-28
### Added
 - Added a list of placeholders to the standalone pages, so wee can determine
     when they have been replaced using the new contains_placeholders? method on
     the page model.

## [3.0.8] - 2023-06-27
### Changed
 - Replace inline event handlers with event listeners to meet CSP requirements

## [3.0.7] - 2023-06-26
### Changed
 - Update Editable components to use custom element for simpler progressive
     enhancement and refactoring & improving in the editor.

## [3.0.6] - 2023-06-22
### Added
 - Update Editable Content areas to use a custom element - a more declarative and
     native solution. Works as an editor when JS is present, and a simple html
     output when the custom element is not upgraded by JS.

## [3.0.5] - 2023-06-21
### Changed
 - Protect against XSS (reflected) attack.

## [3.0.4] - 2023-06-20
### Changed
 - Ensure filenames with extension `jfif` or `jpg` use `jpeg` when uploaded. This is to match the file that is attached on submission/confirmation emails.

## [3.0.3] - 2023-06-09
### Changed
 - Updated grid traversal to ensure traversal of all routes to fix bugs where
     pages were appearing disconnected when they shouldn't be.

## [3.0.2] - 2023-05-25
### Changed
 - Implementation of retrieving the service slug has changed, we now call the `service_slug_config`
    method in the application controller.

## [3.0.1] - 2023-05-24
### Added
 - Add in submission complete template, to display on back navigation from
     confirmation page

## [3.0] - 2023-05-22
### Changed

- Update Rails dependency to >= 7.0

## [2.20.1] - 2023-05-22
### Fixed

- Update confirmation page template, moving optional content components into the
    width container.

## [2.20.0] - 2023-05-19
### Changed

- Change `service_name`method to allow for backwards compatibility
- Add `service_slug_config` method to check for `SERVICE_SLUG` config in Runner and Editor

## [2.19.5] - 2023-05-19
### Changed

- Append a suffix to file upload names if they are duplicates

## [2.19.4] - 2023-05-18
### Changed

- Remove unwanted characters from file uploads

## [2.19.3] - 2023-05-10
### Changed

- Small fixes to session management and views

## [2.19.2] - 2023-05-10
### Changed

- Prevent submission of form when clicking save for later on check answers page

## [2.19.1] - 2023-05-10
### Changed

- Fix button html on check answers page

## [2.19] - 2023-04-27
### Changed

 - Add resume saved progress flow - resume page, check secret answer, resume from start if newer version is published or return from resume point.

## [2.18.7] - 2023-04-27
### Changed

 - Update copy on 404 error page. Remove head and body tags as this template
     is always loaded within a layout.

## [2.18.6] - 2023-04-27
### Fixed

 - Fix Editor preview footer links bug

## [2.18.5] - 2023-04-26
### Fixed

 - Fixed spacing between titles and components on multiple question pages.

## [2.18.4] - 2023-04-14

 - Update start page template to new content

## [2.18.3] - 2023-04-13
### Changed

 - Fix bug in save and return flow

## [2.18.2] - 2023-04-05
### Changed

 - Fix back link in save and return flow

## [2.18.1] - 2023-04-05
### Changed

 - Add save and return submit error handling

## [2.18] - 2023-04-05
### Changed

 - Add save and return submit functionality

## [2.17.45] - 2023-03-29
### Changed

 - update helper method from `in_progress?` to `allowed_page?` as it is a more
     accurate and less confusing name.

## [2.17.44] - 2023-03-39
### Changed

- Remove the save and return button temporarily

## [2.17.43] - 2023-03-29
### Changed

 - Changed the templates for the cookie warning banner.  We reload the
     page between the request and the accept or reject banner, so they need to
     be separated into separate partials with different conditions for being
     shown.

## [2.17.42] - 2023-03-29
### Changed

- Changed cookies statement to reflect updated session timeout length.

## [2.17.41] - 2023-03-27
### Added

- Initial save and return page behind feature flag.

## [2.17.40] - 2023-03-20
### Added

 - Added session timeout warning modal.  After 25 minutes of inactivity a
     warning modal will be shown with a 5 minute countdown.  If no action is
     taken the session will be reset and the user redirected.

## [2.17.39] - 2023-03-14
### Added

- Adding test fixture corresponding to the fix of the bug that shows multiple cya and confirmation pages

## [2.17.38] - 2023-03-14
### Fixed

 - Change the cookie statement and the session expired page to reflect updated session timeout length and behaviour.

## [2.17.37] - 2023-02-27
### Fixed

 - Update the output of the `@page.send_body` content in the template to use
    the `to_html` helper like all other content components

## [2.17.36] - 2023-02-06
### Changed

- Use Ruby 3.1.3

## [2.17.35] - 2023-02-07
### Changed

- Update cookie statement from 30 to 60 minutes

## [2.17.34] - 2023-01-27
### Added

 - Added in a session expiry route and template to inform uses when their
     session has expired.

## [2.17.33] - 2023-01-20
### Fixed

- Heading for the confirmation page not being updated when payment links are enabled

## [2.17.32] - 2023-01-03
### Changed

- Use Ruby 2.7.7

## [2.17.31] - 2022-12-20
### Fixed

- Fix preview links when in the Editor

## [2.17.30] - 2022-12-20
### Changed

- Allow the use of fully qualified or relative URLs for the footer links

## [2.17.29] - 2022-12-16
### Added
 - Add continue to pay button to confirmation page if payment link is enabled

## [2.17.28] - 2022-12-12
### Added

- Add logic to change confirmation page style based on whether payment link is enabled.

## [2.17.27] - 2022-12-06
### Changed

- Updated reference number confirmation page content and move to using locales.

## [2.17.26] - 2022-12-05
### Changed

 - Updated Check your answers page to use H2 tags for multiquestion page titles
     to keep logical heading heirarchy correct for accessibility.

## [2.17.25] - 2022-12-01
### Fixed

- Fixed error in MaxSizeValidator human_max_size when size was a string.

## [2.17.24] - 2022-11-23
### Added

- Add reference number to confirmation page
- Provide methods to ensure reference number is correct when in the Editor and Runner apps

## [2.17.23] - 2022-10-27

### Added

- Added the ability to display a maintenance page for an individual form, based
    on the presence of ENV config values.

## [2.17.22] - 2022-09-09

### Fixed

- Updated previous commit to use a better value  after an issue was found (same intention for change applies)

### Added
## [2.17.21] - 2022-09-08

### Added

- Tweak to allow static Cookie content to be found in content searches

## [2.17.20] - 2022-08-25

### Changed

- Move locales into a presenter specific property scope
- Add content for footer pages

## [2.17.19] - 2022-08-24

### Changed

 - Remove deprecated govuk-header__link--service-name class now govuk-frontend
     update is live in editor.

## [2.17.18] - 2022-08-23

### Changed

 - Changes required by upgrading to govuk-frontend 4.3.1

## [2.17.17] - 2022-08-17

### Changed

- Standalone template to pull Cookie statement content from locales file as a temporary solution to centralise this content.

## [2.17.16] - 2022-08-08

### Added

 - Ability to manually inject properties into Global Analytics

## [2.17.15] - 2022-08-04

### Fixed

 - Autocomplete validator key is `autocomplete`

## [2.17.14] - 2022-08-03

### Added

 - Add autocomplete validator for when a user answer is not a valid select item

## [2.17.13] - 2022-07-27

### Added

 - Add govuk 'accessible-autocomplete' component

### Changed

 - Reorganize scripts and styles

## [2.17.12] - 2022-07-28

### Added

- Add autocomplete countries fixture
- Add ability to extract the text from an autocomplete answer when used on a checkanswers page
- Add 'autocomplete?' method to the component model

### Changed

- Update autocomplete page schema to include an items property
- Remove items property from the select schema
- Change the AutocompleteItem model id method to return both the text and value as a JSON string
- Override to_json method on the component model to remove 'items' from the return JSON string

## [2.17.11] - 2022-07-22

### Fixed

- Cookie banner should only show if MoJ analytics on or form owner has set

## [2.17.10] - 2022-07-20

### Added

- Add `AutocompleteItem` model, this maps the metadata structure of an autocomplete item
- Instantiate AutocompleteItem object when the component is of type autocomplete
- Assign the autocomplete items for the preview functionality, using the `autocomplete_items` method

### Fixed

- Fixed issue where page components were `nil`

## [2.17.9] - 2022-07-18

### Changed

- Cookie banner always shows unless controlling cookie present
- Global (MoJ Forms) analytics always included, if analytics allowed
- Global (MoJ Forms) analytics ID is different from Form Owner settings
- Form Owner settings only shows if allowed and set

## [2.17.8] - 2022-07-12

### Changed

- Removed graphviz dependency and rake task which used it to build flows
- Moved the editable functionalties of the autocomplete component to the Editor app

## [2.17.7] - 2022-07-04

### Added

- Added 2 new mime types
- Added meta tag to exclude from indexing

## [2.17.6] - 2022-06-29

### Added

- Autocomplete view template

### Changed

- Update autocomplete schema
- Update the start now button label to correct casing

## [2.17.5] - 2022-06-28

### Fixed

- Check whether the global_ga4 has actually been set on the Rails config object

## [2.17.4] - - 2022-06-27

### Changed

 - Update button label for check answers page to 'Submit'
 - Move button labels into locales file
 - Changed analytics_tag to measurement_id

### Added

- Added MoJ Forms GA4 global analytics partials

## [2.17.3] - 2022-06-24

### Changed

- Move definitions to component level rather than definition level, this is in
  line with the existing component schemas.

## [2.17.2] - 2022-06-16

### Changed

- Rename autocomplete options to items.

## [2.17.1] - 2022-06-09

### Fixed

- Allow for more specific lookup by JS

## [2.17.0] - 2022-06-09

### Fixed

- Fixed issue where pages traversed based on user answers were incomplete and therefore
  missing from submission payloads and generated PDF files

## [2.16.14] - 2022-06-09

### Fixed

- Pass analytics IDs as string literals in JS scripts

## [2.16.13] - 2022-06-08

### Added

- Add google analytics tags to the application layout
- Add cookie banner to the application layout

## [2.16.12] - 2022-06-01

### Changed

 - Updates to ensure character/word remaining count displays for textarea component

## [2.16.11] - 2022-05-27

### Added

- Add autocomplete schemas and default metadata

### Changed

- Format date validation configuration string to a human readable form of DD MM YYYY
- Update validation error message content

## [2.16.10] - 2022-05-20

### Fixed

- Check whether answer is a number before validating minimum and maximum

## [2.16.9] - 2022-05-20

### Fixed

- Check whether date is valid before validating after and before
- Coerce string length validators to integer before comparing user answers

## [2.16.8] - 2022-05-19

- Fix date valdiators which were reversed

### Fixed

## [2.16.7] - 2022-05-17

### Fixed

- Revert the removal of the application JS pack
- Fix incorrect error messages for the date before and date after validations

## [2.16.6] - 2022-05-16

### Added

- date_before and date_after validations
- min_length and max_length default metadata

### Changed

- Change number validation schema types to be strings

## [2.16.5] - 2022-05-09

### Changed

- Small design bug fix to Confirmation page

## [2.16.4] - 2022-05-06

### Added

- Surface supported validations for each component

## [2.16.3] - 2022-05-05

### Added

- Added Minimum validation for the number component
- Added default metadata for minimum validation

### Changed

- Use file path as fallback for naming default metadata keys
- Add schema sub definitions as their own schemas to the JSON validator
- Lock json-schema to version 2.8.1

## [2.16.2] - 2022-04-21

### Changed

- Change method to ensure the confirmation page column coordinate is larger than the CYA page coordinate.

## [2.16.1] - 2022-04-08

### Added

-  Added the correct viewport meta tag from the design system so that the interface displays correctly on devices.

## [2.16.0] - 2022-04-07

### Added

-  Expose previous destination uuids for objects in the flow.

## [2.15.13] - 2022-03-22

### Changed

- Changed weight of radio buttons component labels.

## [2.15.12] - 2022-03-17

### Added

- Add ability to check if page is a multiple question page.

## [2.15.11] - 2022-02-18

### Added

- Add `contains` and `does_not_contain` operators.

## [2.15.10] - 2022-02-14

### Fixed

- Ensure the correct number of branch spacers are calculated when conditionals point to the same page, or when there are 'OR' conditionals in the branching point.

## [2.15.9] - 2022-02-09

### Changed

- Check Confirmation and CYA pages are in the correct column during grid placement.

### Fixed

- Remove excess Pointer objects in the detached grid.

## [2.15.8] - 2022-02-02

### Added

- Update Branching 10 fixture to include 'is answered' branch.

## [2.15.7] - 2022-01-17

### Fixed

- Fix page IDs and URLs in one of the branching fixtures

## [2.15.6] - 2022-01-14

### Changed

- Replace text component with email component in version fixture.

## [2.15.5] - 2022-01-14

### Fixed

- Fix email schema

## [2.15.4] - 2022-01-13

### Changed

- Change order of components on multiple question page
- Change default heading for email component

## [2.15.3] - 2022-01-12

### Added

- Add length validation to email component

## [2.15.2] - 2022-01-10

### Added

- Added email component

## [2.15.1] - 2022-01-07

### Added

- Added a page warning model to check whether the submitting pages will detached from the main flow

## [2.15.0] - 2021-12-30

### Changed

- Use Ruby 2.7.5

## [2.14.1] - 2021-12-20

### Added

- Adjust row numbers for objects to match their corresponding Spacer row from the directly previous column

## [2.14.0] - 2021-12-20

### Added

- Hold the position information for all branch object conditionals

### Changed

- Do not force objects to always use the latest column number

### Fixed

- Allow the linking to objects behind in the flow without breaking it visually

## [2.13.0] - 2021-12-15

### Changed

- Add Warning object to Grid model. To be used if the CYA or Confirmation pages are not in the main flow.

## [2.12.1] - 2021-12-14

### Changed

- Do not allow the overwriting of previously placed Flow objects in the Grid model

## [2.12.0] - 2021-12-14

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
