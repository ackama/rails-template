'use strict';

module.exports = {
  plugins: ['stylelint-scss'],
  extends: ['stylelint-config-standard-scss'],
  reportNeedlessDisables: true,
  reportInvalidScopeDisables: true,
  reportDescriptionlessDisables: true,
  rules: {
    'no-descending-specificity': null,
    'string-no-newline': true,
    'declaration-block-no-duplicate-custom-properties': true,
    'declaration-block-no-duplicate-properties': true,

    // standard-scss expects kebab-case, but we use BEM
    'selector-class-pattern': null,
    'custom-property-pattern': null,

    // standard-scss does not allow empty lines before custom properties
    'custom-property-empty-line-before': [
      'always',
      {
        except: ['first-nested'],
        ignore: [
          'after-custom-property',
          'after-comment',
          'inside-single-line-block'
        ]
      }
    ]
  }
};
