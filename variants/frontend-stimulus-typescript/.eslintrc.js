'use strict';

/** @type {import('eslint').Linter.Config} */
const config = {
  root: true,
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: 'tsconfig.json',
    ecmaVersion: 2019,
    sourceType: 'module'
  },
  env: { commonjs: true, node: true, browser: true },
  extends: ['ackama', 'ackama/@typescript-eslint'],
  ignorePatterns: ['tmp/'],
  overrides: [
    {
      files: ['config/webpack/*', 'babel.config.js', '.eslintrc.js'],
      parserOptions: { sourceType: 'script' },
      rules: {
        '@typescript-eslint/prefer-nullish-coalescing': 'off',
        '@typescript-eslint/no-require-imports': 'off',
        '@typescript-eslint/no-var-requires': 'off',
        'strict': 'error'
      }
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
  ],
  rules: {}
};

module.exports = config;
