#pragma once

#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassBuilder.h"

using namespace llvm;

namespace llvm 
{

class HelloWorld : public PassInfoMixin<HelloWorld>
{
public:
    HelloWorld() { }
    PreservedAnalyses run(Function& F, FunctionAnalysisManager& AM);
    static bool isRequired() { return true; } 
    static constexpr StringRef pass_name = "hello_world";
};

HelloWorld* create_hello_world_pass();

}
