'use strict';

const config = {
  clearMocks: true,
  restoreMocks: true,
  resetMocks: true,

  testEnvironment: 'jsdom',

  testPathIgnorePatterns: ['config/'],
  setupFilesAfterEnv: [
    '@testing-library/jest-dom/extend-expect',
    './app/frontend/test/setupExpectEachTestHasAssertions.js'
  ]
};

module.exports = config;
