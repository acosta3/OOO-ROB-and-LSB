#ifndef _ROB_H
#define _ROB_H

#include <vector>
#include "MemTemplate.h"
namespace ns3
{
    class ROB
    {
        private:
            int MAX_ENTRIES;
            int num_entries;
            int IPC;
            std::vector<CpuFIFO::ReqMsg*> rob_q;
        public:
            ROB(int max_entries = 32, int ipc = 4){
                MAX_ENTRIES = max_entries;
                IPC = ipc;
                rob_q = std::vector<CpuFIFO::ReqMsg*>();
                num_entries = 0;
            }
            void step(){
                retire();
            }
            bool canAccept(){
                return num_entries < MAX_ENTRIES;
            }
            void allocate(CpuFIFO::ReqMsg* request){
                if (request->type == CpuFIFO::REQTYPE::COMPUTE){
                    commit(request);
                }

                rob_q.push_back(request);
                num_entries++;
            }
            void retire(){
                int num_retired = 0;
     
                while ((rob_q.size() > 0) && (rob_q.front()->ready) && (num_retired < IPC)){
                    //rob_q.erase(rob_q.begin());
                    
                    CpuFIFO::ReqMsg* temp_ptr = rob_q.front();
                    temp_ptr->done[0] = true;
                    rob_q.erase(rob_q.begin());
                    num_retired++;
                    num_entries--;
                    if (temp_ptr->done[0] && temp_ptr->done[1]){
                      delete temp_ptr;
                    }
                    //std::cerr << "HELLO\n";
                      //  std::cerr << "HELLO\n";
                    // exit(1);
                }
            
            }
            void commit(CpuFIFO::ReqMsg* request){
                request->ready = true;
            }
    };

}

#endif /* _ROB_H */
