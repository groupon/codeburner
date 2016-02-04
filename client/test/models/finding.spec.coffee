# global beforeEach, describe, it, assert, expect
"use strict"

describe 'Finding Model', ->
  beforeEach ->
    @FindingModel = new Codeburner.Models.Finding();
