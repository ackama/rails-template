'use strict';

const configAckamaBase = require('eslint-config-ackama');
const configAckamaJest = require('eslint-config-ackama/jest');
const configAckamaTypeScript = require('eslint-config-ackama/typescript');
const pluginJestDOM = require('eslint-plugin-jest-dom');
const pluginTestingLibrary = require('eslint-plugin-testing-library');

/** @type {import('eslint').Linter.FlatConfig[]} */
const config = [
  { files: ['**/*.{js,jsx,cjs,mjs,ts,tsx,cts,mts}'] },
  { ignores: ['tmp/*'] },
  ...configAckamaBase,
  ...configAckamaTypeScript,
  { languageOptions: { parserOptions: { project: true } } },
  {
    files: ['config/webpack/*', 'babel.config.js', 'eslint.config.js'],
    languageOptions: { sourceType: 'commonjs' },
    rules: {
      '@typescript-eslint/prefer-nullish-coalescing': 'off',
      '@typescript-eslint/no-require-imports': 'off',
      '@typescript-eslint/no-var-requires': 'off',
      'strict': 'error'
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
