const configAckamaBase = require('eslint-config-ackama');
const globals = require('globals');

/** @type {import('eslint').Linter.FlatConfig[]} */
const config = [
  { files: ['**/*.{js,jsx,cjs,mjs}'] },
  { ignores: ['tmp/*'] },
  ...configAckamaBase,
  {
    files: ['config/webpack/*', 'babel.config.js', 'eslint.config.js'],
    languageOptions: {
      sourceType: 'script',
      globals: { ...globals.node }
    },
    rules: {}
  }
];

module.exports = config;
