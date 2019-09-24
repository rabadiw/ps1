$semvertest = '1.0.0-alpha.1-1-64ef335'

Describe "SemVer Tests" {
  Context "Default" {
    It "ConvertTo-SemVer should pass" {
      $exp = @{
        Major    = 1
        Minor    = 0
        Patch    = 0
        Pre      = "alpha"
        PrePatch = 1
      }
      $act = ConvertTo-SemVer -semver $semvertest
      $act | Should -BeOfType System.Collections.Hashtable
      $act.Major | Should -Be $exp.Major
      $act.Minor | Should -Be $exp.Minor
      $act.Patch | Should -Be $exp.Patch
      $act.Pre | Should -Be $exp.Pre
      $act.PrePatch | Should -Be $exp.PrePatch
    }

    It "Format-SemVerString should pass" {
      $exp = '1.0.0-alpha.1'
      $act = ConvertTo-SemVer $semvertest | Format-SemVerString
      $act | Should -Be $exp
    }

    It "Set-Semver major should pass" {
      $exp = 'What if: git tag 1.0.0-beta.0'
      $act = Set-SemVer -semverb major -semver $semvertest -WhatIf
      $act | Should -Be $exp
    }

    It "Set-Semver minor should pass" {
      $exp = 'What if: git tag 1.0.0-alpha.2'
      $act = Set-SemVer -semverb minor -semver $semvertest -WhatIf
      $act | Should -Be $exp
    }

    It "Set-Semver patch should pass" {
      $exp = 'What if: git tag 1.0.0-alpha.2'
      $act = Set-SemVer -semverb patch -semver $semvertest -WhatIf
      $act | Should -Be $exp
    }

    It "Set-Semver major should pass - take 2" {
      $exp = 'What if: git tag 2.0.0'
      $act = Set-SemVer -semverb major -semver "1.0.0" -WhatIf
      $act | Should -Be $exp
    }
    It "Set-Semver minor should pass - take 2" {
      $exp = 'What if: git tag 1.1.0'
      $act = Set-SemVer -semverb minor -semver "1.0.0" -WhatIf
      $act | Should -Be $exp
    }
    It "Set-Semver patch should pass - take 2" {
      $exp = 'What if: git tag 1.0.1'
      $act = Set-SemVer -semverb patch -semver "1.0.0" -WhatIf
      $act | Should -Be $exp
    }
  }
}
