# i18n module for internationalization

def resolve-locale [
  locale: oneof<string, nothing>
] {
  if ($locale == null) {
    auto-detect-locale
  } else {
    $locale
  }
}

# initialize i18n with given locale
export def --env init [
  i18n: record # of locale records
  locale: oneof<string, nothing> = null # optional locale
] {
  set-locale (resolve-locale $locale)
  merge-i18n $i18n
}
# merge additional i18n records
export def --env merge-i18n [
  additional: record # of locale records
] {
  $env.i18n = ($env.i18n? | default {}) | merge $additional
}
# get i18n record for current locale
export def i18n-with-locale [] {
  let i18n = ($env.i18n? | default {})
  let locale = ($env.locale? | default (auto-detect-locale))

  ($i18n | get --ignore-case --optional $locale) | default {}
}

# set current locale
export def --env set-locale [
  locale: string # desired locale
] {
  $env.locale = $locale
}
# auto-detect system locale
export def auto-detect-locale [] {
  locale -u
}
# translate key using current locale
export def tr [
  key: string # key to translate
]: nothing -> oneof<string, nothing> {
  i18n-with-locale | get --ignore-case --optional $key
}
# translate key with variable replacement
export def trf [
  key: string # key to translate
  vars: record # variables for replacement
]: nothing -> oneof<string, nothing> {
  let template = tr $key
  if ($template == null) {
    null
  } else if ($template | is-empty) {
    null
  } else {
    (
      $vars
      | transpose k v
      | reduce --fold $template {|row acc|
        $acc | str replace $"{{($row.k)}}" ($row.v | into string)
      }
    )
  }
}
