#!/bin/bash
IS30_6=no
IS30_8=no
IS_OLD=no

function getcode()
{
    repo sync -j4
    echo "--------------------------------"
    echo "------Repo sync OK--------------"
    repo start $1 --all
    echo "--------------------------------"
    echo "-------git branch OK------------"
}

function gitCloneCode()
{
    if [ x$1 == x"GMS" ] ||  [ x$1 == x"GMS_Above5.0" ] || [ x$1 == x"GMS_backup" ] || [ x$1 == x"GMS_6.0_E183L" ];then
    {
        echo "start:git clone git3@10.0.30.6:external/google/$1.git "
        git clone git3@10.0.30.6:external/google/$1.git
    }    
    elif [ x$1 == x"SCMHelper_SW1" ] ; then
    {
        echo "start:git clone git3@10.0.30.6:external/helper/SCMHelper_SW1.git "
        git clone git3@10.0.30.6:external/helper/SCMHelper_SW1.git
    }    
    else
       echo "Error Parameter!!!"
    fi
}


function cddir()
{

    case $1 in
        GMS|GMS_Above5.0|SCMHelper_SW1|GMS_6.0_E183L)
        if [ x$2 == x"" ] ; then
            if [  -d ./$1 ] ;then
            {
                cd $1
                git pull
             }
            else 
                gitCloneCode $1
            fi 
   
        else
            if [ ! -d ./$2 ] ; then
            {
                mkdir $2
                cd $2
                gitCloneCode $1
            }
            else
            {
                cd $2
                if [ -d ./$1 ]; then
                {
                    cd $1
                    git pull
                }
                else
                {
                    gitCloneCode $1
                }
               fi
            }    
            fi
        fi
        exit 1
        ;;  
        mt6572|S300W|S511W|S311W|S506W)
            PROJECT=MT6572_4_4
            BRANCH=master
            IS30_6=yes
        ;;
        kk_modem)
            PROJECT=MT6592_KK/modem
            BRANCH=master
            IS30_6=yes
        ;;
        kk|T651W_KK|T651W_MX|S800W)
            PROJECT=MT6592_KK
            BRANCH=Master_SW1
            IS30_6=yes
        ;;
        S610W)
            PROJECT=MT6592_KK
            BRANCH=Master_SW1_MT6592_KK
            IS30_6=yes
        ;;  
        T651W)
            PROJECT=MT6582_4_2
            BRANCH=Master_SW1
            IS30_6=yes
        ;;
        M3)
            PROJECT=MT6572W_4_2
            BRANCH=Stable_Mass_M3_BRH
            IS30_6=yes
        ;; 
        S300W_MXI)
        PROJECT=MT6572_4_4
        BRANCH=Stable_Mass_S300W_IUC_MX_QB25SA_P172B20V1.0.1B04_BRH
        IS30_6=yes
        ;;
        S300W_VE)
        PROJECT=MT6572_4_4
        BRANCH=Stable_Mass_DIS_VE_QB25DA_P172B20V1.0.0B05_BRH
        IS30_6=yes
        ;;                  
        S300W_MODEM)
        PROJECT=MT6572_4_4/tools/modem
        BRANCH=master
        IS30_6=yes
		IS_OLD=yes
        ;;
        S660)
        PROJECT=MT6592_4_4
        BRANCH=master
        IS30_6=yes
        ;;
        S660_MODEM)
        PROJECT=MT6592_4_4/modem
        BRANCH=master
        IS30_6=yes
        ;;       
        A300L|A110L|A210L|A211F|A215F|A301L|A302L|A303L|A305F|A310F|A331L|MT6752_KK)
        PROJECT=MT6752_KK
        BRANCH=master
        IS30_6=no
        ;;
        A300L_SFC)
        PROJECT=MT6752_KK
        BRANCH=Stable_Mass_SFC_A300L_K00_V1.0B10_BRH
        IS30_6=no
        ;;
        A110L_DDM)
        PROJECT=MT6752_KK
        BRANCH=Stable_Mass_DDM_A110F_K00V1.0B04_BRH
        IS30_6=no
        ;;
        A310F_BENQ)
        PROJECT=MT6752_KK
        BRANCH=Stable_Mass_BNQ_A310F_K20_V1.0B11_20141212_BRH
        IS30_6=no
        ;;
		A310F_BENQ)
        PROJECT=MT6752_KK
        BRANCH=Stable_Mass_BNQ_A310F_K20_V1.0B11_20141212_BRH
        IS30_6=no
        ;;
        A300L_MODEM|MT6752_MODEM)
        PROJECT=MT6752_KK/modem
        IS30_6=no        
        ;;    
        MT6735_L|V350L_old|MT6735_old)
        PROJECT=MT6735_L
        BRANCH=master
        IS30_6=no
        ;; 
		MT6735_L_GINREEN|MT6735)
        PROJECT=MT6735_L_GINREEN
        BRANCH=master
        IS30_6=no
        ;; 
		V350L)
        PROJECT=MT6735_L_GINREEN
        BRANCH=Stable_Mass_V350L_TCL_P620M_V1.0_150430_BRH
        IS30_6=no
        ;; 
		V351L)
        PROJECT=MT6735_L_GINREEN
        BRANCH=Stable_Mass_V351L_TCL_P596_V1.0_150924_BRH
        IS30_6=no
        ;; 
		V351L_Tmp)
        PROJECT=MT6735_L_GINREEN
        BRANCH=Tmp_V351L_TCL_P596_V1.0_150924_BRH
        IS30_6=no
        ;; 
        MT6735M_L|V200F_old)
        PROJECT=MT6735M_L1
        BRANCH=master
        IS30_6=no
        ;;
        V200F)
        PROJECT=MT6735M_L1_GINREEN_TMO
        BRANCH=master
        IS30_6=no
        ;;
        V200F_BRH)
        PROJECT=MT6735M_L1_GINREEN_TMO
        BRANCH=Stable_Mass_P675T07V1.0.0B18_BRH
        IS30_6=no
        ;;
        V200F_TY)
        PROJECT=MT6735M_L1_GINREEN_TMO
        BRANCH=Generic
        IS30_6=no
        ;;
        V200F_METRO|V200F_Metro)
        PROJECT=MT6735M_L1_GINREEN_TMO
        BRANCH=Metro
        IS30_6=no
        ;;
        V200F_modem)
        PROJECT=MT6735M_L1_GINREEN_TMO/modem
        BRANCH=master
        IS30_6=no
        ;;
        V200F_VOLTE)
        PROJECT=MT6735M_L1_VOLTE_GINREEN_TMO_SW1
        BRANCH=master
        IS30_6=no
        ;;
        V200F_MPCS)
        PROJECT=MT6735M_L1_VOLTE_GINREEN_TMO_SW1
        BRANCH=Stable_Mass_MPCS_P675T07V1.0.0B11_BRH
        IS30_6=no
        ;;
        V200F_MR3)
        PROJECT=MT6735M_L1_VOLTE_GINREEN_TMO_SW1
        BRANCH=Stable_Mass_MPCS_P675T07V1.0.0B10_BRH
        IS30_6=no
        ;;
        V200F_MPCS_modem)
        PROJECT=MT6735M_L1_VOLTE_GINREEN_TMO_SW1/modem
        BRANCH=Stable_Mass_MPCS_P675T07V1.0.0B11_BRH
        IS30_6=no
        ;;
        V200F_TMO)
        PROJECT=MT6735M_L1_VOLTE_GINREEN_TMO_SW1
        BRANCH=Stable_Mass_P675T07V1.0.0B28_BRH
        IS30_6=no
        ;;
        V200F_VOLTE_modem)
        PROJECT=MT6735M_L1_VOLTE_GINREEN_TMO_SW1/modem
        BRANCH=master
        IS30_6=no
        ;;
        E183|E183L)
        PROJECT=GR6753_65T_M0_V39_SW1
        BRANCH=PDU1
        IS30_8=yes
        ;;
        E183_modem|E183L_modem)
        PROJECT=GR6753_65T_M0_V39_SW1/modem
        BRANCH=PDU1
        IS30_8=yes
        ;;
        E183_VOLTE|E183L_VOLTE|E188_VOLTE|E188F_VOLTE)
        PROJECT=GR6753_65T_A_M0_VOLTE_SW1
        BRANCH=PDU1
        IS30_8=yes
        ;;
        E183_VOLTE_modem|E183L_VOLTE_modem|E188_VOLTE_modem|E188F_VOLTE_modem)
        PROJECT=GR6753_65T_A_M0_VOLTE_SW1/modem
        BRANCH=PDU1
        IS30_8=yes
        ;;
        D265|D265_ZUK|ZUK|D265X)
        PROJECT=GR6750_66_ZUK_N_SW1
        BRANCH=PDU1
        IS30_8=yes
        ;;
        D265_modem|D265X_modem|ZUK_Modem)
        PROJECT=GR6750_66_ZUK_N_SW1/modem
        BRANCH=PDU1
        IS30_8=yes
        ;;
        A158)
        PROJECT=GR6737T_65_LE_N_SW1
        BRANCH=PDU1
        IS30_8=yes
        ;;
        A158_modem)
        PROJECT=GR6737T_65_LE_N_SW1/modem
        BRANCH=PDU1
        IS30_8=yes
        ;;
        A183)
        PROJECT=GR6737M_65_A_M0_V2115_SW1
        BRANCH=PDU1
        IS30_8=yes
        ;;
        A183_modem)
        PROJECT=GR6737M_65_A_M0_V2115_SW1/modem
        BRANCH=PDU1
        IS30_8=yes
        ;;
        E270|E270L)
        PROJECT=GR6580_WE_M_SW1
        BRANCH=PDU1
        IS30_8=yes
        ;;
        E270_modem|E270L_modem)
        PROJECT=GR6580_WE_M_SW1/modem
        BRANCH=PDU1
        IS30_8=yes
        ;;
        P100)
        PROJECT=SAMSUNG_5430_SW1
        BRANCH=master
        IS30_6=yes
        ;;
        V215F|V215|GINR6735M)
        PROJECT=GINR6735M_65C_L
        BRANCH=master
        IS30_6=no
        ;;
        V215F_modem|GINR6735M_modem)
        PROJECT=GINR6735M_65C_L/modem
        BRANCH=master
        IS30_6=no
        ;;
	E164L|E169F|E200L|E165L|GINR6753|V310F)
        PROJECT=GINR6753_65C_L1_SW1
        BRANCH=master
        IS30_6=no
        ;;
	E169F_ASI)
        PROJECT=GINR6753_65C_L1_SW1
        BRANCH=Stable_Mass_ASIA_CHA_P635F33V1.0.0B12_BRH
        IS30_6=no
        ;;
	E169F_TW)
        PROJECT=GINR6753_65C_L1_SW1
        BRANCH=Stable_Mass_TW_P635F32V1.0.0B09_BRH
        IS30_6=no
        ;;
	E169F_FASTWEB)
        PROJECT=GINR6753_65C_L1_SW1
        BRANCH=Stable_Mass_FWB_IT_P635F33V1.0.0B03_BRH
        IS30_6=no
        ;;
	E169F_SPAL)
        PROJECT=GINR6753_65C_L1_SW1
        BRANCH=Stable_Mass_DIS_IT_P635F33V1.0.0B03_BRH
        IS30_6=no
        ;;
	E169F_SP)
        PROJECT=GINR6753_65C_L1_SW1
        BRANCH=Stable_Mass_DIS_SPN_P635F33V1.0.0B05_BRH
        IS30_6=no
        ;;
	E169F_EUR)
        PROJECT=GINR6753_65C_L1_SW1
        BRANCH=Stable_Mass_DIS_EU_P635F33V1.0.0B07_BRH
        IS30_6=no
        ;;
	E169F_NOS)
        PROJECT=GINR6753_65C_L1_SW1
        BRANCH=Stable_Mass_NOS_PT_P635F33V1.0.0B05_BRH
        IS30_6=no
        ;;
	E169F_CHK)
        PROJECT=GINR6753_65C_L1_SW1
        BRANCH=E169F_ASI_BRH
        IS30_6=no
        ;;
	E167L)
        PROJECT=GINR6753_65C_L1_SW1
        BRANCH=Stable_Mass_P635N33V1.0.0B06_BRH
        IS30_6=no
        ;;
	E164L_modem|E169F_modem|V310F_modem|GINT6753_modem|MT6753_modem)
        PROJECT=GINR6753_65C_L1_SW1/modem
        BRANCH=master
        IS30_6=no
        ;;
        E165L_CMCC|E165L_VOLTE)
        PROJECT=MT6753_VOLTE_L1_SW1
        BRANCH=master
        IS30_6=yes
        ;;
	E165L_CMCC_modem|E165L_VOLTE_modem)
        PROJECT=MT6753_VOLTE_L1_SW1/modem
        BRANCH=master
        IS30_6=yes
        ;;
		GINR6572_L|6572_L1|6572_L)
        PROJECT=GINR6572_WET_L_SW1
        BRANCH=master
        IS30_6=yes
        ;;
		GINR6572_L_modem|6572_L1_modem|6572_L_modem)
        PROJECT=GINR6572_WET_L_SW1/modem
        BRANCH=master
        IS30_6=yes
        ;;
        MT6735M_modem|MT6735_modem)
        PROJECT=MT6735M_L/modem
        BRANCH=master
        IS30_6=no
        ;;                                 
        T500_B15)        
            PROJECT=IC8825
            BRANCH=Stable_Mass_T500_WIND_P825T10V1.0.0B15_BRH
            IS30_6=yes
        ;;

        mt6582)
            PROJECT=MT6582_4_2
            BRANCH=master
            IS30_6=yes
            ;;    
        V215F|V215|GINR6735M)
        PROJECT=GINR6735M_65C_L
        BRANCH=master
        IS30_6=no
        ;;
		E164L|GINR6753|V310F)
        PROJECT=GINR6753_65C_L1
        BRANCH=master
        IS30_6=no
        ;;
		E164L_modem|V310F_modem|GINT6753_modem|MT6753_modem)
        PROJECT=MT6753_65C_L1/modem
        BRANCH=master
        IS30_6=no
        ;;
        V215F_modem|GINR6735M_modem)
        PROJECT=GINR6735M_65C_L/modem
        BRANCH=master
        IS30_6=no
        ;;
        MT6735M_modem|MT6735_modem)
        PROJECT=MT6735M_L/modem
        BRANCH=master
        IS30_6=no
        ;;                                 
        T500_B15)        
            PROJECT=IC8825
            BRANCH=Stable_Mass_T500_WIND_P825T10V1.0.0B15_BRH
            IS30_6=yes
        ;;

        mt6582)
            PROJECT=MT6582_4_2
            BRANCH=master
            IS30_6=yes
        ;;
        mt6589)
            PROJECT=MT6589_4_2
            BRANCH=master
            IS30_6=yes
        ;;
        modem6589)
            PROJECT=MT6589_4_2/modem
            BRANCH=master
            IS30_6=yes
        ;;
        T621)
            PROJECT=MT6572_4_2
            BRANCH=master
            IS30_6=yes
        ;;
        T621W)
            PROJECT=MT6572W_4_2
            BRANCH=master
            IS30_6=yes
        ;;

        T651W_new)
            PROJECT=MT6582_4_2
            BRANCH=Master_SW1_P182A10
            IS30_6=yes
        ;;
        L301)
            PROJECT=bcm21553
            BRANCH=Stable_L301_P253A20GV1.0.0B05_BRH
            IS30_6=yes
        ;;
        MT6592)
            PROJECT=MT6592_4_2
            BRANCH=master
            IS30_6=yes
        ;;
        modem82_master)
            PROJECT=MT6582_4_2/modem
            BRANCH=master
            IS30_6=yes
        ;;
        modem82_SW1)
            PROJECT=MT6582_4_2/modem
            BRANCH=Master_SW1
            IS30_6=yes
        ;;
        modem_92)
            PROJECT=MT6592_4_2/modem
            BRANCH=master
            IS30_6=yes
        ;;
		--help)
		    helpfunction
			exit 1
		;;	
        *)
            echo "First Parameter:Project Name"
            echo "Second Parameter:Path Name"
            exit 1
    esac

        Destdir=$2
        if [ "$2" = "" ] ; then
            echo  -e "\033[35m Second Parameter can't be null!\033[0m"
            exit 1
        fi
        confirm_URI 
        #echo -e "\n" | repo init -u git3@10.0.30.6:${PROJECT}/tools/manifest.git -b ${BRANCH}

}

function helpfunction(){

	echo -e "\033[34mFirst Parameter:Project Name"
	echo "Second Parameter:Path Name"
	echo -e "Project Name:\033[0m"
    echo -e -n "\033[33mGMS\033[0m"
	echo -e  "\033[34m(no need Second Parameter)\033[0m"
	echo -e "\033[33mMT6735M_L  :  MT6735M_L V200F MT6735M"
    echo "MT6735_L   :  MT6735_L V350L MT6735"
	echo "MT6752_KK  :  A300L A110L A210L A211F A215F A301L A302L A303L A305F A310F A331L MT6752_KK A310F_BENQ A110L_DDM A300L_SFC"
	echo "MT6572_4_4 :  mt6572 S300W S311W S511W S311W S506W  S300W_MXI S300W_VE"
	echo "MT6592_KK  :  kk T651W_KK T651W_MX S800W S610W"
	echo -e "Modem      :  MT6735M_modem MT6735_modem S300W_MODEM A300L_MODEM MT6752_MODEM kk_modem  \033[0m"
	echo -e "\033[34m Other parameters , please check  merge_all.sh on yourself.\033[0m"
	echo -e "\n"

}

function confirm_URI(){
    if [ $IS30_6 = "yes" ] ; then
		serverIP=git3@10.0.30.6
    elif [ $IS30_8 = "yes" ]; then
        serverIP=git@10.0.30.8
	else
		serverIP=git@10.0.30.7
	fi	
	if [ $IS_OLD = "yes" ] ; then
		echo -e "\033[33mrepo init -u ${serverIP}:${PROJECT}/manifest.git -b ${BRANCH}\033[0m"
	else
		echo -e "\033[33mrepo init -u ${serverIP}:${PROJECT}/tools/manifest.git -b ${BRANCH}\033[0m"
	fi
	read -n1 -p  "Is URI correct ? [Y/N]" answer
	case $answer in
		Y | y | yes | Yes)
		echo -e "\n"
		if [ -d ./$Destdir ]; then
			echo "dir  exists, go ahead"		

		else
           	echo "mkdir $Destdir"
			mkdir $Destdir
		fi
		cd $Destdir
	    if [ $IS_OLD = "yes" ] ; then
			echo -e "\n" | repo init -u ${serverIP}:${PROJECT}/manifest.git -b ${BRANCH}
		else
			echo -e "\n" | repo init -u ${serverIP}:${PROJECT}/tools/manifest.git -b ${BRANCH}
		fi
		getcode master 
		cd -
	;;
		*)
		echo -e "\n"
		return 1; 
	;;
	esac
  
        
    
}

cddir $1 $2
