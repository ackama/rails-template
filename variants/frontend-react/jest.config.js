const config = {
  testEnvironment: 'node',
  clearMocks: true,
  restoreMocks: true,
  resetMocks: true,

  moduleDirectories: ['node_modules', 'app/frontend'],

  setupFilesAfterEnv: ['app/frontend/tests/setupExpectEachTestHasAssertions.js']
};

export default config;
