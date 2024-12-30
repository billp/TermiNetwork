# Changelog

## [4.1](https://github.com/billp/TermiNetwork/tree/4.1) (2024-12-30)

[Full Changelog](https://github.com/billp/TermiNetwork/compare/4.0...4.1)

**Implemented enhancements:**

- Add support for Xcode 16.x [\#59](https://github.com/billp/TermiNetwork/issues/59)
- Refactor upload operations to restrict users from giving any type of values [\#56](https://github.com/billp/TermiNetwork/issues/56)
- Refactor upload operations to restrict users from giving any type of … [\#58](https://github.com/billp/TermiNetwork/pull/58) ([billp](https://github.com/billp))

**Closed issues:**

- Unable to upload files. Wrong body type and exception is thrown [\#55](https://github.com/billp/TermiNetwork/issues/55)
- Issue with interceptors and catching errors. [\#54](https://github.com/billp/TermiNetwork/issues/54)

**Merged pull requests:**

- Add support for Xcode 16.x \(\#59\) [\#60](https://github.com/billp/TermiNetwork/pull/60) ([billp](https://github.com/billp))

## [4.0](https://github.com/billp/TermiNetwork/tree/4.0) (2023-04-24)

[Full Changelog](https://github.com/billp/TermiNetwork/compare/3.2.0...4.0)

**Closed issues:**

- SwiftUI Image: support modifier instead of using TermiNetwork.Image view [\#45](https://github.com/billp/TermiNetwork/issues/45)
- Name refactor to align with the Repository pattern  [\#35](https://github.com/billp/TermiNetwork/issues/35)

**Merged pull requests:**

- Name refactor to align with the Repository pattern \(35\) [\#53](https://github.com/billp/TermiNetwork/pull/53) ([billp](https://github.com/billp))

## [3.2.0](https://github.com/billp/TermiNetwork/tree/3.2.0) (2022-12-16)

[Full Changelog](https://github.com/billp/TermiNetwork/compare/3.1.1...3.2.0)

**Implemented enhancements:**

- Write test cases covering task cancelation [\#44](https://github.com/billp/TermiNetwork/issues/44)
- Wrap all async functions with withTaskCancellationHandler that cancels the request if needed [\#43](https://github.com/billp/TermiNetwork/issues/43)
- Support task cancellation on async functions [\#42](https://github.com/billp/TermiNetwork/issues/42)

**Closed issues:**

- Unescape escaped slashes of response from logger [\#49](https://github.com/billp/TermiNetwork/issues/49)
- Fix duplicated debug print on codable deserialisation error [\#46](https://github.com/billp/TermiNetwork/issues/46)
- No need to handle middleware if there is already an error [\#40](https://github.com/billp/TermiNetwork/issues/40)
- Change access level of Transformer's internal protocol type [\#37](https://github.com/billp/TermiNetwork/issues/37)

**Merged pull requests:**

- Support task cancellation on async functions \(\#42\) [\#51](https://github.com/billp/TermiNetwork/pull/51) ([billp](https://github.com/billp))
- Unescape escaped slashes of response from logger \(\#49\) [\#50](https://github.com/billp/TermiNetwork/pull/50) ([billp](https://github.com/billp))
- Fix duplicated debug print on codable deserialisation error \(\#46\) [\#47](https://github.com/billp/TermiNetwork/pull/47) ([billp](https://github.com/billp))
- if there is already an error, then no need to handle the middleware [\#39](https://github.com/billp/TermiNetwork/pull/39) ([voynovia](https://github.com/voynovia))

## [3.1.1](https://github.com/billp/TermiNetwork/tree/3.1.1) (2022-12-04)

[Full Changelog](https://github.com/billp/TermiNetwork/compare/3.1.0...3.1.1)

**Closed issues:**

- Add support for async/await  [\#34](https://github.com/billp/TermiNetwork/issues/34)

**Merged pull requests:**

- Change access level of Transformer's internal protocol type \(\#37\) [\#38](https://github.com/billp/TermiNetwork/pull/38) ([billp](https://github.com/billp))

## [3.1.0](https://github.com/billp/TermiNetwork/tree/3.1.0) (2022-12-01)

[Full Changelog](https://github.com/billp/TermiNetwork/compare/3.0.0...3.1.0)

**Closed issues:**

- Update pinning test certificate [\#32](https://github.com/billp/TermiNetwork/issues/32)

**Merged pull requests:**

- Add support for async/await \(\#34\) [\#36](https://github.com/billp/TermiNetwork/pull/36) ([billp](https://github.com/billp))
- Update pinning test certificate \(\#32\) [\#33](https://github.com/billp/TermiNetwork/pull/33) ([billp](https://github.com/billp))

## [3.0.0](https://github.com/billp/TermiNetwork/tree/3.0.0) (2021-12-29)

[Full Changelog](https://github.com/billp/TermiNetwork/compare/2.1.1...3.0.0)

**Implemented enhancements:**

- Implement HPKP \(HTTP Public Key Pinning\) [\#20](https://github.com/billp/TermiNetwork/issues/20)
- Add network reachability [\#18](https://github.com/billp/TermiNetwork/issues/18)
- Increase test coverage  [\#17](https://github.com/billp/TermiNetwork/issues/17)

**Fixed bugs:**

- Update heroku ssl certificate [\#24](https://github.com/billp/TermiNetwork/issues/24)

**Closed issues:**

- Remove integration with Travis [\#28](https://github.com/billp/TermiNetwork/issues/28)
- Support Xcode 13.x [\#26](https://github.com/billp/TermiNetwork/issues/26)
- Disable Reachability for watchOS [\#22](https://github.com/billp/TermiNetwork/issues/22)
- Remove deprecated functions and classes [\#19](https://github.com/billp/TermiNetwork/issues/19)

**Merged pull requests:**

- Increase test coverage \(\#17\) [\#31](https://github.com/billp/TermiNetwork/pull/31) ([billp](https://github.com/billp))
- Remove integration with Travis \(\#28\) [\#29](https://github.com/billp/TermiNetwork/pull/29) ([billp](https://github.com/billp))
- Issue 26 support Xcode 13.x [\#27](https://github.com/billp/TermiNetwork/pull/27) ([billp](https://github.com/billp))
- Update heroku ssl certificate \(\#24\) [\#25](https://github.com/billp/TermiNetwork/pull/25) ([billp](https://github.com/billp))

## [2.1.1](https://github.com/billp/TermiNetwork/tree/2.1.1) (2021-02-02)

[Full Changelog](https://github.com/billp/TermiNetwork/compare/2.1.0...2.1.1)

## [2.1.0](https://github.com/billp/TermiNetwork/tree/2.1.0) (2021-02-02)

[Full Changelog](https://github.com/billp/TermiNetwork/compare/2.0.1...2.1.0)

**Merged pull requests:**

- Disable Reachability for watchOS \(\#22\) [\#23](https://github.com/billp/TermiNetwork/pull/23) ([billp](https://github.com/billp))
- Add network reachability \(\#18\) [\#21](https://github.com/billp/TermiNetwork/pull/21) ([billp](https://github.com/billp))

## [2.0.1](https://github.com/billp/TermiNetwork/tree/2.0.1) (2021-01-14)

[Full Changelog](https://github.com/billp/TermiNetwork/compare/2.0.0...2.0.1)

**Closed issues:**

- Update TestPinning test cases to use the new response callbacks [\#14](https://github.com/billp/TermiNetwork/issues/14)
- Fix testQueueFailureModeCancelAll test case [\#13](https://github.com/billp/TermiNetwork/issues/13)
- Remove warning about operation queue when its finished but never started [\#12](https://github.com/billp/TermiNetwork/issues/12)

**Merged pull requests:**

- Remove warning about operation queue when its finished but never started \(fixes \#12\) [\#16](https://github.com/billp/TermiNetwork/pull/16) ([billp](https://github.com/billp))
- Update TestPinning test cases to use the new response callbacks \(fixes \#14\) [\#15](https://github.com/billp/TermiNetwork/pull/15) ([billp](https://github.com/billp))

## [2.0.0](https://github.com/billp/TermiNetwork/tree/2.0.0) (2021-01-14)

[Full Changelog](https://github.com/billp/TermiNetwork/compare/1.0.5...2.0.0)

**Closed issues:**

- Change deprecated calls from Request [\#10](https://github.com/billp/TermiNetwork/issues/10)
- Change the way of getting the response [\#8](https://github.com/billp/TermiNetwork/issues/8)

**Merged pull requests:**

- Change deprecated calls from Request \(fixes \#10\) [\#11](https://github.com/billp/TermiNetwork/pull/11) ([billp](https://github.com/billp))
- Change the way of getting the response \(fixes \#8\) [\#9](https://github.com/billp/TermiNetwork/pull/9) ([billp](https://github.com/billp))

## [1.0.5](https://github.com/billp/TermiNetwork/tree/1.0.5) (2020-12-29)

[Full Changelog](https://github.com/billp/TermiNetwork/compare/1.0.4...1.0.5)

## [1.0.4](https://github.com/billp/TermiNetwork/tree/1.0.4) (2020-12-29)

[Full Changelog](https://github.com/billp/TermiNetwork/compare/1.0.3...1.0.4)

## [1.0.3](https://github.com/billp/TermiNetwork/tree/1.0.3) (2020-12-28)

[Full Changelog](https://github.com/billp/TermiNetwork/compare/1.0.2...1.0.3)

## [1.0.2](https://github.com/billp/TermiNetwork/tree/1.0.2) (2020-12-28)

[Full Changelog](https://github.com/billp/TermiNetwork/compare/1.0.1...1.0.2)

## [1.0.1](https://github.com/billp/TermiNetwork/tree/1.0.1) (2020-12-28)

[Full Changelog](https://github.com/billp/TermiNetwork/compare/1.0.0...1.0.1)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
