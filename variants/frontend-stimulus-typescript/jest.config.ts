import { Config } from 'jest';

const config: Config = {
  testEnvironment: 'jsdom',
  clearMocks: true,
  restoreMocks: true,
  resetMocks: true,

  testPathIgnorePatterns: ['config/'],
  setupFilesAfterEnv: [
    './app/frontend/test/setupJestDomMatchers.ts',
    './app/frontend/test/setupExpectEachTestHasAssertions.ts'
  ]
};

export default config;
