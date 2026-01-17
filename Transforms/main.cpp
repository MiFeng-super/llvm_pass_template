
#include "llvm/Passes/PassPlugin.h"

#include "include/HelloWord.h"

extern "C" LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() 
{
    return {
        LLVM_PLUGIN_API_VERSION, "HelloWorld", LLVM_VERSION_STRING,
        [](PassBuilder& PB)
        {
            PB.registerPipelineParsingCallback([](StringRef Name, FunctionPassManager &FPM, ArrayRef<PassBuilder::PipelineElement>)
			{
				if (Name == HelloWorld::pass_name)
				{
					FPM.addPass(HelloWorld());
                    return true;
				}
				else 
				{
					return false;
				}
			});
        }
    };
}