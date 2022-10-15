module.exports = {
  plugins: ['stylelint-scss'],
  extends: ['stylelint-config-recommended-scss'],
  rules: {
    'no-descending-specificity': null,
    'string-no-newline': true,
    'color-no-invalid-hex': true,
    'comment-whitespace-inside': 'always',
    'declaration-block-no-duplicate-custom-properties': true,
    'declaration-block-no-duplicate-properties': true,
    'no-invalid-double-slash-comments': true,
    'no-duplicate-at-import-rules': true,
    'no-invalid-position-at-import-rule': true,
    'length-zero-no-unit': true
  }
};
