# Changelog

Not all changes will be here, but the important ones will be for sure.

## 0.4.0

* Added Cassanity::Client to make setup easier ([pull request](https://github.com/jnunemaker/cassanity/pull/8))
* Added easy instrumenting of CQL calls and a log subscriber ([pull request](https://github.com/jnunemaker/cassanity/pull/9))
* Added prettier inspecting of all the things
* Added #batch to Keyspace and ColumnFamily [commit](https://github.com/jnunemaker/cassanity/commit/1a6393b)
* Allow setting default keyspace and column family names when performing a batch
* Added Cassanity::Range and Cassanity.range shortcuts for range queries. [commit](5834d9e)
* Allow passing hash as schema instead of forcing Cassanity::Schema instance

## 0.3.0

* Changed [update counter value API](https://github.com/jnunemaker/cassanity/commit/a0f5a76)
* Added [support for range queries](https://github.com/jnunemaker/cassanity/commit/5d89ada)

## 0.2.2

* Added [Keyspace#column_families](https://github.com/jnunemaker/cassanity/commit/8101835)
* Added [ColumnFamily#recreate and exists?](https://github.com/jnunemaker/cassanity/commit/11a5739)
* Added [Keyspace#exist? and ColumnFamily#exist?](https://github.com/jnunemaker/cassanity/commit/9fe88ab)

## 0.2.1

* Added [using, order and limit clauses](https://github.com/jnunemaker/cassanity/compare/414d780...3aeb254) to column family select
