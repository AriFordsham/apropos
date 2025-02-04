module Apropos (
  -- Apropos.Type
  Apropos (..),
  (:+),
  -- Apropos.LogicalModel
  LogicalModel (..),
  -- Apropos.LogicalModel.Enumerable
  Enumerable (..),
  -- Apropos.LogicalModel.Formula
  Formula (..),
  -- Apropos.HasLogicalModel
  HasLogicalModel (..),
  -- Apropos.Gen
  Gen,
  label,
  failWithFootnote,
  bool,
  int,
  list,
  shuffle,
  element,
  choice,
  genFilter,
  retry,
  -- Apropos.Gen.Range
  Range,
  linear,
  singleton,
  -- Apropos.HasParameterisedGenerator
  HasParameterisedGenerator (..),
  runGeneratorTest,
  runGeneratorTestsWhere,
  enumerateGeneratorTest,
  enumerateGeneratorTestsWhere,
  genSatisfying,
  -- Apropos.HasPermutationGenerator
  HasPermutationGenerator (..),
  Morphism (..),
  Abstraction (..),
  abstract,
  abstractsProperties,
  (|:->),
  -- Apropos.HasPermutationGenerator.Contract
  Contract,
  runContract,
  readContractInput,
  readContractEdgeName,
  readContractOutput,
  writeContractOutput,
  branches,
  branchIf,
  has,
  hasn't,
  hasAll,
  hasNone,
  add,
  addIf,
  addAll,
  addAllIf,
  remove,
  removeIf,
  removeAll,
  removeAllIf,
  clear,
  output,
  contractError,
  terminal,
  -- Apropos.Pure
  HasPureRunner (..),
) where

import Apropos.Gen
import Apropos.HasLogicalModel
import Apropos.HasParameterisedGenerator
import Apropos.HasPermutationGenerator
import Apropos.HasPermutationGenerator.Contract
import Apropos.LogicalModel
import Apropos.Pure
import Apropos.Type
