{-# LANGUAGE TypeFamilies #-}

module Spec.IntPermutingGen (
  intPermutingGenTests,
  intPermutingGenDeviceTests,
  intPermutingGenPlutarchTests,
  intPermutingGenSelfTests,
  ) where
import Proper.HasLogicalModel
import Proper.LogicalModel
import Proper.HasParameterisedGenerator
import Proper.IsDeviceModel
import Proper.PermutingGenerator
import Proper.IsPlutusModel
import SAT.MiniSat ( Formula (..) )
import Hedgehog (Gen)
import qualified Hedgehog.Gen as Gen
import Hedgehog.Range (linear)
import Data.Proxy (Proxy(..))
import Test.Tasty (TestTree,testGroup)
import Test.Tasty.Hedgehog (fromGroup)
import qualified Data.Set as Set

import Plutarch (compile)
import Plutarch.Prelude

data IntProp =
      IsNegative
    | IsPositive
    | IsZero
    | IsLarge
    | IsSmall
    | IsMaxBound
    | IsMinBound
    deriving stock (Eq,Ord,Enum,Show,Bounded)

instance LogicalModel IntProp where
  logic = ExactlyOne [Var IsNegative, Var IsPositive, Var IsZero]
     :&&: ExactlyOne [Var IsLarge, Var IsSmall]
     :&&: (Var IsZero :->: Var IsSmall)
     :&&: (Var IsMaxBound :->: (Var IsLarge :&&: Var IsPositive))
     :&&: (Var IsMinBound :->: (Var IsLarge :&&: Var IsNegative))

instance HasLogicalModel Int IntProp where
  satisfiesProperty i IsNegative = i < 0
  satisfiesProperty i IsPositive = i > 0
  satisfiesProperty i IsMaxBound = i == maxBound
  satisfiesProperty i IsMinBound = i == minBound
  satisfiesProperty i IsZero     = i == 0
  satisfiesProperty i IsLarge    = i > 10 || i < -10
  satisfiesProperty i IsSmall    = i <= 10 && i >= -10

instance PermutingGenerator Int IntProp where
  generators =
    [ PermutationEdge
      { name = "MakeZero"
      , match = Not $ Var IsZero
      , contract = \_ -> Set.fromList [IsZero,IsSmall]
      , permuteGen = \_ -> pure 0
      }
    , PermutationEdge
      { name = "MakeMaxBound"
      , match = Not $ Var IsMaxBound
      , contract = \_ -> Set.fromList [IsMaxBound,IsLarge,IsPositive]
      , permuteGen = \_ -> pure maxBound
      }
    , PermutationEdge
      { name = "MakeMinBound"
      , match = Not $ Var IsMinBound
      , contract = \_ -> Set.fromList [IsMinBound,IsLarge,IsNegative]
      , permuteGen = \_ -> pure minBound
      }
    , PermutationEdge
      { name = "MakeLarge"
      , match = Not $ Var IsLarge
      , contract = \_ -> Set.fromList [IsLarge, IsPositive]
      , permuteGen = \_ -> Gen.int (linear 11 (maxBound -1))
      }
    , PermutationEdge
      { name = "MakeSmall"
      , match = Not $ Var IsSmall
      , contract = \_ -> Set.fromList [IsSmall,IsPositive]
      , permuteGen = \_ -> Gen.int (linear 1 10)
      }
    , PermutationEdge
      { name = "NegatePos"
      , match = Var IsPositive
      , contract = Set.delete IsPositive . Set.insert IsNegative
      , permuteGen = \i -> pure (-i)
      }
    , PermutationEdge
      { name = "NegateNeg"
      , match = Var IsNegative
      , contract = Set.delete IsNegative . Set.insert IsPositive
      , permuteGen = \i -> pure (-i)
      }
    ]

instance HasParameterisedGenerator Int IntProp where
  parameterisedGenerator = buildGen baseGen

baseGen :: Gen Int
baseGen = (Gen.int (linear minBound maxBound))

intPermutingGenTests :: TestTree
intPermutingGenTests = testGroup "Spec.IntPermutingGen" $
    fromGroup <$> [
      runGeneratorTestsWhere (Proxy :: Proxy Int) "Int Generator" (Yes :: Formula IntProp)
    ]

acceptsSmallNegativeInts :: Device Int IntProp
acceptsSmallNegativeInts = Device (Var IsSmall :&&: Var IsNegative)
                                  (\i -> i < 0 && i >= -10)

instance IsDeviceModel Int IntProp

intPermutingGenDeviceTests :: TestTree
intPermutingGenDeviceTests = testGroup "Device.AcceptsSmallNegativeInts" $
  fromGroup <$> [
    runDeviceTestsWhere acceptsSmallNegativeInts "AcceptsSmallNegativeInts" Yes
  ]

instance IsPlutusModel Int IntProp where
  expect _ _ = Var IsSmall :&&: Var IsNegative
  script _ i =
    let ii = (fromIntegral i) :: Integer
     in compile (pif (((fromInteger ii) #< ((fromInteger 0) :: Term s PInteger)) #&& (((fromInteger (-10)) :: Term s PInteger) #<= (fromInteger ii))) (pcon PUnit) perror)

intPermutingGenPlutarchTests :: TestTree
intPermutingGenPlutarchTests = testGroup "Plutarch.AcceptsSmallNegativeInts" $
  fromGroup <$> [
    runScriptTestsWhere (Proxy :: Proxy Int) (Proxy :: Proxy IntProp) "AcceptsSmallNegativeInts" Yes
  ]

intPermutingGenSelfTests :: TestTree
intPermutingGenSelfTests = testGroup "Int PermutingGenerator selfTest" $
  fromGroup <$> selfTest (\(_ :: PermutationEdge Int IntProp) -> True) baseGen


