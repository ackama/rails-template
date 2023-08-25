'use strict';

const config = {
  root: true,
  env: { commonjs: true, node: true, browser: true },
  extends: ['ackama'],
  ignorePatterns: ['tmp/'],
  parserOptions: { sourceType: 'module', ecmaVersion: 2022 },
  overrides: [
    {
      files: ['.eslintrc.js'],
      parserOptions: { sourceType: 'script' }
    },
    {
      files: ['app/frontend/test/**'],
      extends: [
        'ackama/jest',
        'plugin:jest-dom/recommended',
        'plugin:testing-library/dom'
      ],
      plugins: ['testing-library', 'jest-dom'],
      rules: {
        'jest/prefer-expect-assertions': 'off'
      }
    }
  ]
};

module.exports = config;
