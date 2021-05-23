const config = {
  testEnvironment: 'node',
  clearMocks: true,
  restoreMocks: true,
  resetMocks: true,

  moduleDirectories: ['node_modules', 'app/frontend'],

  setupFilesAfterEnv: [
    '@testing-library/jest-dom/extend-expect',
    'app/frontend/test/setupExpectEachTestHasAssertions.js'
  ]
};

export default config;
