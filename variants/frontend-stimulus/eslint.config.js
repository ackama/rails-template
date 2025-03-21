'use strict';

const configAckamaBase = require('eslint-config-ackama');
const configAckamaJest = require('eslint-config-ackama/jest');
const pluginJestDOM = require('eslint-plugin-jest-dom');
const pluginTestingLibrary = require('eslint-plugin-testing-library');
const globals = require('globals');

/** @type {import('eslint').Linter.FlatConfig[]} */
const config = [
  { files: ['**/*.{js,jsx,cjs,mjs}'] },
  { ignores: ['tmp/*'] },
  ...configAckamaBase,
  {
    ignores: ['config/webpack/*', 'babel.config.js', 'eslint.config.js'],
    languageOptions: { globals: { ...globals.browser } }
  },
  {
    files: ['config/webpack/*', 'babel.config.js', 'eslint.config.js'],
    languageOptions: {
      sourceType: 'commonjs',
      globals: { ...globals.node }
    }
  },
  ...[
    pluginJestDOM.configs['flat/recommended'],
    pluginTestingLibrary.configs['flat/dom'],
    ...configAckamaJest,
    /** @type {import('eslint').Linter.FlatConfig} */ ({
      rules: { 'jest/prefer-expect-assertions': 'off' }
    })
  ].map(c => ({ ...c, files: ['app/frontend/test/**'] }))
];

module.exports = config;
