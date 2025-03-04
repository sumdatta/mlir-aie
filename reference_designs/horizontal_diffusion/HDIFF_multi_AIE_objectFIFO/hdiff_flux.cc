/*  (c) 2023 SAFARI Research Group at ETH Zurich, Gagandeep Singh, D-ITET             */

// #include <adf.h>
#include "./include.h"
#include "hdiff.h"
#define kernel_load 14
// typedef int int32;


// void hdiff_flux(int32_t * restrict in, int32_t * restrict  flux_forward,  int32_t * restrict out)
// {
void hdiff_flux(int32_t* restrict row1, int32_t* restrict row2,int32_t* restrict row3, int32_t* restrict flux_forward1,int32_t* restrict flux_forward2,int32_t* restrict flux_forward3,int32_t* restrict flux_forward4,  int32_t * restrict out)
{
    
    alignas(32) int32_t weights1[8] = {1,1,1,1,1,1,1,1};
    alignas(32) int32_t flux_out[8]={-7,-7,-7,-7,-7,-7,-7,-7};

    v8int32 coeffs1         = *(v8int32*) weights1;  //  8 x int32 = 256b W vector
    v8int32 flux_out_coeff=*(v8int32*)flux_out;

    // v8int32 * restrict  ptr_in = (v8int32 *) in;
    v8int32 * restrict  ptr_forward = (v8int32 *) flux_forward1;
    v8int32 * ptr_out = (v8int32 *) out;
    
    v8int32 * restrict row1_ptr=(v8int32 *)row1;
    v8int32 * restrict row2_ptr=(v8int32 *)row2;
    v8int32 * restrict row3_ptr=(v8int32 *)row3;

    v8int32 * restrict r1=(v8int32 *)row1_ptr;
    v8int32 * restrict r2=(v8int32 *)row2_ptr;

    // v8int32 * restrict row0_ptr=(v8int32 *)row0;
    // v8int32 * restrict row1_ptr=(v8int32 *)row1;
    // v8int32 * restrict row2_ptr=(v8int32 *)row2;

    v16int32   data_buf1=null_v16int32();
    v16int32  data_buf2=null_v16int32();

    v8acc80 acc_0=null_v8acc80();
    v8acc80 acc_1=null_v8acc80();
          //  8 x int32 = 256b W vector

  
        // r1 = ptr_in + 1*COL/8 + aor*COL/8;
        // r2 = ptr_in + 2*COL/8 + aor*COL/8;
        data_buf1 = upd_w(data_buf1, 0, *r1++);
        data_buf1 = upd_w(data_buf1, 1, *r1);

        data_buf2 = upd_w(data_buf2, 0, *r2++);
        data_buf2 = upd_w(data_buf2, 1, *r2);

        
    // buf_2=R2 , and buf_1=R3
        
    for (unsigned i = 0; i < COL/8; i++)
        chess_prepare_for_pipelining
        chess_loop_range(1,)
        {
            v8int32  flux_sub;
            // printf("inside flux");
            // v8acc80 acc_flux = concat(get_scd_v4acc80(),get_scd_v4acc80());
            // flx_imj=window_readincr_v8(flux_cascade); //flx_imj
            ptr_forward = (v8int32 *) flux_forward1;
            flux_sub=*ptr_forward;
            // flux_sub=window_readincr_v8(flux_cascade);
            acc_1=lmul8   (data_buf2,2,0x76543210,flux_sub,    0,0x00000000);           // (lap_ij - lap_ijm)*g
            acc_1=lmsc8   (acc_1,data_buf2,1,0x76543210,flux_sub,    0,0x00000000);     // (lap_ij - lap_ijm)*g - (lap_ij - lap_ijm)*f

            // compare > 0
            unsigned int flx_compare_imj=gt16(concat(srs(acc_1,0),undef_v8int32()),0,0x76543210,0xFEDCBA98, null_v16int32(),0,0x76543210,0xFEDCBA98); 
                        
            // //Calculate final fly_ijm
            v16int32 out_flx_inter1=select16(flx_compare_imj,concat(flux_sub,undef_v8int32()),null_v16int32()); 

            v16int32 flx_out1=add16(null_v16int32(),out_flx_inter1);     //still fly_ijm
                
    /////////////////////////////////////////////////////////////////////////////////////
            // acc_flux = concat(get_scd_v4acc80(),get_scd_v4acc80());
            // flux_sub=window_readincr_v8(flux_cascade);
            ptr_forward = (v8int32 *) flux_forward2;
            flux_sub=*ptr_forward;
            
            acc_0=lmul8   (data_buf2,3,0x76543210,flux_sub,    0,0x00000000);            // (lap_ijp - lap_ij) * h       
            acc_0=lmsc8   (acc_0,data_buf2,2,0x76543210,flux_sub,    0,0x00000000);      //  (lap_ijp - lap_ij) * h  - (lap_ijp - lap_ij) * g           

            //Calculates final fly_ij (comparison > 0)
            unsigned int flx_compare_ij=gt16(concat(srs(acc_0,0),undef_v8int32()),0,0x76543210,0xFEDCBA98, null_v16int32(),0,0x76543210,0xFEDCBA98); 
            v16int32 out_flx_inter2=select16(flx_compare_ij,concat(flux_sub,undef_v8int32()),null_v16int32());    

            //add fly_ij - fly_ijm
            v16int32 flx_out2=sub16(out_flx_inter2,flx_out1);                             
/////////////////////////////////////////////////////////////////////////////////////

            /// retrieving flx_imj = lap_ij - lap_imj
            // acc_flux = concat(get_scd_v4acc80(),get_scd_v4acc80());
            // flux_sub=window_readincr_v8(flux_cascade);
            ptr_forward = (v8int32 *) flux_forward3;
            flux_sub=*ptr_forward;
            acc_1=lmul8   (data_buf2,2,0x76543210,flux_sub,    0,0x00000000);       //   (lap_ij - lap_imj) * g
            acc_1=lmsc8   (acc_1,data_buf1,2,0x76543210,flux_sub,    0,0x00000000); //    (lap_ij - lap_imj) * g  *  (lap_ij - lap_imj) * c  
            
          
            
            r1=row3_ptr+i;

            data_buf1 = upd_w(data_buf1, 0, *r1++);
            data_buf1 = upd_w(data_buf1, 1, *r1);
            
            //Calculates final flx_imj (comparison > 0)
            unsigned int fly_compare_ijm=gt16(concat(srs(acc_1,0),undef_v8int32()),0,0x76543210,0xFEDCBA98, null_v16int32(),0,0x76543210,0xFEDCBA98); 
            v16int32 out_flx_inter3=select16(fly_compare_ijm,concat(flux_sub,undef_v8int32()),null_v16int32());

            v16int32 flx_out3=sub16(flx_out2,out_flx_inter3);                     //adds fly_ij - fly_ijm - flx_imj
/////////////////////////////////////////////////////////////////////////////////////
             // acc_flux = concat(get_scd_v4acc80(),get_scd_v4acc80());
             //re†rieving flx_ij = lap_ipj - lap_ij
            // flux_sub=window_readincr_v8(flux_cascade);
            ptr_forward = (v8int32 *) flux_forward4;
            flux_sub=*ptr_forward;

            //below reuisng acc_1 for flux calculation //CHANGED FROM 3 TO 2
            acc_1=lmul8   (data_buf1,2,0x76543210,flux_sub,    0,0x00000000);      //  (lap_ipj - lap_ij) * k       

            acc_1=lmsc8   (acc_1,data_buf2,2,0x76543210,flux_sub,    0,0x00000000);    //  (lap_ipj - lap_ij) * k - (lap_ipj - lap_ij) * g   

            
            // r1 = ptr_in + 1*COL/8 + i+1+ aor*COL/8;
            r1=row1_ptr+i;
            data_buf1 = upd_w(data_buf1, 0, *r1++);
            data_buf1 = upd_w(data_buf1, 1, *r1);
     

            // final flx_ij (comparison > 0 )
            unsigned int fly_compare_ij=gt16(concat(srs(acc_1,0),undef_v8int32()),0,0x76543210,0xFEDCBA98, null_v16int32(),0,0x76543210,0xFEDCBA98); 
            v16int32 out_flx_inter4=select16(fly_compare_ij,concat(flux_sub,undef_v8int32()),null_v16int32()); 

            v16int32 flx_out4=add16(flx_out3,out_flx_inter4); //adds fly_ij - fly_ijm - flx_imj + flx_ij

            v8acc80 final_output = lmul8  (flx_out4, 0, 0x76543210, flux_out_coeff,    0,0x00000000);  // Multiply by -7s
            final_output=lmac8(final_output, data_buf2,  2, 0x76543210,concat(coeffs1, undef_v8int32()), 0 , 0x76543210); 


          //LOAD DATA FOR NEXT ITERATION
            
         
            r2=row2_ptr+i;
            // data_buf1=*r1++;
            data_buf2 = upd_w(data_buf2, 0, *r2++);
            data_buf2 = upd_w(data_buf2, 1, *r2);

            // window_writeincr(out, srs(final_output,0));
            *ptr_out++ =  srs(final_output,0);  
                      
        }
    

}
