#ifndef _LSB_H
#define _LSB_H

#include <vector>
#include "MemTemplate.h"
namespace ns3
{
    class LSB
    {
        private:
            int MAX_ENTRIES;
            int num_entries;
            std::vector<CpuFIFO::ReqMsg*> lsb_q;
            CpuFIFO* m_cpuFIFO;
            int index_to_be_retired;
        public:
            LSB(){

            }
            LSB(CpuFIFO* associatedFIFO, int max_entries = 8){
                MAX_ENTRIES = max_entries;
                lsb_q = std::vector<CpuFIFO::ReqMsg*>();
                m_cpuFIFO = associatedFIFO;
                index_to_be_retired = -1;
                num_entries = 0;
            }
            void step(){
                pushToCache();
                retire();
            }
            bool canAccept(){
                return num_entries < MAX_ENTRIES;
            }
            bool allocate(CpuFIFO::ReqMsg* request){
                if (request->type == CpuFIFO::REQTYPE::WRITE){
                    commit(request);
                    
                } else {
                
                    if (!lsb_q.empty()){
                        for (int i = lsb_q.size() - 1; i >= 0; i--){
                            if ((lsb_q[i]->addr == request->addr) && (lsb_q[i]->type == CpuFIFO::REQTYPE::WRITE)){
                                ldFwd(request, lsb_q[i]);
                                commit(request);
                                num_entries++;
                                lsb_q.push_back(request);
                                //std::cerr << "HIT\n";
                                return true;
                            }
                        }
                    }
                }
                //std::cerr << "MESSAGE ID: " << request->msgId << "\n";
                lsb_q.push_back(request);
                num_entries++;
                return false;
            }
            void retire(){
                for (int i = lsb_q.size() - 1; i >= 0; i--){
                    if (((lsb_q[i]->type == CpuFIFO::REQTYPE::READ) && (lsb_q[i]->ready)) || (index_to_be_retired == i)){
                        CpuFIFO::ReqMsg* temp_ptr = lsb_q[i]; 
                        temp_ptr->done[1] = true;
                        lsb_q.erase(lsb_q.begin()+i);
                        num_entries--;
                    	if (temp_ptr->done[0] && temp_ptr->done[1]){
                      	   delete temp_ptr;
                    	}
                    }
                }
                index_to_be_retired = -1;
            }
            void ldFwd(CpuFIFO::ReqMsg* request, CpuFIFO::ReqMsg* prevStore){
                //fwd data but there is no data what the heck?!?!?!
            }
            void commit(CpuFIFO::ReqMsg* request){
                request->ready = true;
            }
            void pushToCache(){
                //std::cerr << "MESSAGE ID: " << request.msgId << "\n";
                if (!lsb_q.empty()){
                   if (!lsb_q.front()->sent){
                    m_cpuFIFO->m_txFIFO.InsertElement(*(lsb_q.front()));
                    //std::cerr << lsb_q.front()->addr << " " << lsb_q.front()->type << "\n";
                    lsb_q.front()->sent = true;
                    //exit(1);
                    }
                }
            }
            CpuFIFO::RespMsg rxFromCache(){
                CpuFIFO::RespMsg m_cpuMemResp = m_cpuFIFO->m_rxFIFO.GetFrontElement();
                m_cpuFIFO->m_rxFIFO.PopElement();
                //exit(1);
                for (int i = 0; i < lsb_q.size(); i++){
                    if (m_cpuMemResp.msgId == lsb_q[i]->msgId){
                        index_to_be_retired = i;
                        commit(lsb_q[i]);
                    }
                }
                
                return m_cpuMemResp;

            }
    };
}

#endif /* _LSB_H */
