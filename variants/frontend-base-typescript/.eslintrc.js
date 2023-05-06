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
        '@typescript-eslint/no-var-requires': 'off'
      }
    }
  ],
  rules: {}
};

module.exports = config;
