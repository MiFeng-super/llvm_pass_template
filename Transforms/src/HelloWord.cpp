#include "HelloWord.h"

PreservedAnalyses HelloWorld::run(Function& F, FunctionAnalysisManager& AM)
{  
    errs() << "Checking function: " << F.getName() << "\n";
    return PreservedAnalyses::all();
}

HelloWorld* create_hello_world_pass()
{
    return new HelloWorld();
}
