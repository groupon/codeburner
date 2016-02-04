# global beforeEach, describe, it, assert, expect
"use strict"

describe 'Burn Model', ->
  beforeEach ->
    @BurnModel = new Codeburner.Models.Burn();
