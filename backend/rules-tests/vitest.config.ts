import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    include: ['test/**/*.test.ts'],
    // Every file talks to the same emulator database and clears it in
    // beforeEach, so files must run one at a time.
    fileParallelism: false,
    testTimeout: 20000,
    hookTimeout: 30000,
  },
});
