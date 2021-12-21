


IFS=$'\n'

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

read -p "What file do you want to read? " filename

if [[ $(find $filename) ]]
then
 for line in $(cat $filename)
 do

  username=`echo $line | cut -d : -f1`;
  group=`echo $line | cut -d : -f2`;
  pass=`echo $line | cut -d : -f3`;
  shell=`echo $line | cut -d : -f4`;	
  
  changed_group=``
  changed_pass=``
  changed_shell=``

  if [[ $(grep $username /etc/passwd) ]]
  then
   read -p "Do you want to change something for $username? [yes/no] " answer_change

   case $answer_change in
    [Yy][Ee][Ss]|Y|y)
     if [[ $(id -Gn $username) == $(grep $group /etc/group | cut -d : -f1) ]]
     then
      echo "Group for user $username is already exists";
     else
      read -p "Do you want to change primary group for $username? [yes/no] " answer_group

      case $answer_group in
       [Yy][Ee][Ss]|Y|y)
        if [[ !$(grep $group /etc/group) ]]
        then
         groupadd $group;
        fi
        changed_group=$group
        usermod -g $group $username;
      esac
 
     fi
 
     read -p "Do you want to change password for $username? [yes/no] " answer_pass
 
     case $answer_pass in

      [Yy][Ee][Ss]|Y|y)
       changed_pass=$pass;
       password=$(openssl passwd -1 $pass);
     esac	
 
     read -p "Do you want to change shell for $username? [yes/no] " answer_shell
 
     case $answer_shell in
      [Yy][Ee][Ss]|Y|y)
       if [[ $(echo $SHELL) == $shell ]]
       then
        echo "This user alredy have this shell"
       else
        chsh -s $shell $username;
        changed_shell=$shell;
       fi
     esac

     echo -e "Changed users were \n ${YELLOW}$username${NC}: 
     group - ${RED}$changed_group${NC}; 
     password - ${RED}$changed_pass${NC}; 
     shell - ${RED}$changed_shell${NC};"
   esac

  else
   read -p "Do you want to create a new user with name $username? [yes/no] " answer_create

   case $answer_create in
    [Yy][Ee][Ss]|Y|y)
     useradd -m $username -g $group -p $(openssl passwd -crypt $pass) -s $shell;
     echo -e "Newly added users were \n ${GREEN}$username${NC}: group - $group; password - $pass; shell - $shell;"
   esac

  fi
 done
else
 echo "Sorry, file $filename was not found"
fi

