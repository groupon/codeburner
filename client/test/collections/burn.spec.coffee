# global beforeEach, describe, it, assert, expect
"use strict"

describe 'Burn Collection', ->
  beforeEach ->
    @BurnCollection = new Codeburner.Collections.Burn()
