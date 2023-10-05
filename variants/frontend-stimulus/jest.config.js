'use strict';

const config = {
  clearMocks: true,
  restoreMocks: true,
  resetMocks: true,

  testEnvironment: 'jsdom',

  testPathIgnorePatterns: ['config/'],
  setupFilesAfterEnv: [
    './app/frontend/test/setupJestDomMatchers.js',
    './app/frontend/test/setupExpectEachTestHasAssertions.js'
  ]
};

module.exports = config;
