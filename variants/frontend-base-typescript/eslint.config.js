const configAckamaBase = require('eslint-config-ackama');
const configAckamaTypeScript = require('eslint-config-ackama/typescript');
const globals = require('globals');

/** @type {import('eslint').Linter.FlatConfig[]} */
const config = [
  { files: ['**/*.{js,jsx,cjs,mjs,ts,tsx,cts,mts}'] },
  { ignores: ['tmp/*'] },
  ...configAckamaBase,
  ...configAckamaTypeScript,
  { languageOptions: { parserOptions: { project: true } } },
  {
    files: ['config/webpack/*', 'babel.config.js', 'eslint.config.js'],
    languageOptions: {
      sourceType: 'script',
      globals: { ...globals.node }
    },
    rules: {
      '@typescript-eslint/prefer-nullish-coalescing': 'off',
      '@typescript-eslint/no-require-imports': 'off',
      '@typescript-eslint/no-var-requires': 'off'
    }
  }
];

module.exports = config;
