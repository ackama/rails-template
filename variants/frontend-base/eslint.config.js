'use strict';

const configAckamaBase = require('eslint-config-ackama');
const globals = require('globals');

/** @type {import('eslint').Linter.FlatConfig[]} */
const config = [
  { files: ['**/*.{js,jsx,cjs,mjs}'] },
  { ignores: ['tmp/*'] },
  ...configAckamaBase,
  {
    ignores: [
      'config/webpack/*',
      'babel.config.js',
      'eslint.config.js',
      'jest.config.js',
      '.stylelintrc.js'
    ],
    languageOptions: {
      globals: {
        ...globals.browser,
        process: 'readonly'
      }
    }
  },
  {
    files: [
      'config/webpack/*',
      'babel.config.js',
      'eslint.config.js',
      'jest.config.js',
      '.stylelintrc.js'
    ],
    languageOptions: {
      sourceType: 'commonjs',
      globals: { ...globals.node }
    }
  },
  {
    files: ['app/frontend/packs/*.js'],
    languageOptions: { globals: { require: 'readonly' } }
  }
];

module.exports = config;
