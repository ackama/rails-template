import { Config } from '@jest/types';
import 'ts-jest';

const config: Config.InitialOptions = {
  globals: {
    'ts-jest': {
      // disable type checking when running tests, speeding them up and making
      // the development experience nicer by not blocking tests on types
      isolatedModules: true
    }
  },

  testEnvironment: 'jsdom',
  clearMocks: true,
  restoreMocks: true,
  resetMocks: true,

  testPathIgnorePatterns: ['config/'],
  setupFilesAfterEnv: [
    '@testing-library/jest-dom/extend-expect',
    './app/frontend/test/setupExpectEachTestHasAssertions.ts'
  ],

  transform: {
    [/\.tsx?/u.source]: 'ts-jest'
  }
};

export default config;
