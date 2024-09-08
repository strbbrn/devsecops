module.exports = {
  branches: [
    { name: 'master' },
    { name: 'develop', prerelease: 'dev' }, // Adds "-dev" to version (e.g., 1.0.0-dev)
  ],
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    '@semantic-release/changelog',
    '@semantic-release/npm',
    '@semantic-release/github',
    '@semantic-release/git',
  ],
};
