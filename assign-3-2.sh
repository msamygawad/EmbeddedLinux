
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.4.50.tar.xz

#tool needed in the "make -j40 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- all" command
sudo apt update
sudo apt install libssl-dev

#building the kernal using default config
make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- mrproper
make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- defconfig
make -j40 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- all
make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- modules
make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- dtbs

#building the rootfs
cd .. 
mkdir rootfs #create a directory for rootfs
cd rootfs #change directory to rootfs
mkdir bin dev etc home lib lib64 proc sbin sys tmp usr var usr/bin usr/lib usr/sbin var/log
cd .. 

#building busybox
git clone git://busybox.net/busybox.git #clone the busybox repository
cd busybox  #cahnge directory to busybox
git checkout 1_33_1 #version specified in the assignment
make distclean #clean previous builds (ifany)
make defconfig #use default config
make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- #build busybox
make CONFIG_PREFIX=../rootfs ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- install #install busybox
#it is recomended to change the "busybox" binary to root ownership to avoid any permission issues
sudo chown root:root busybox && sudo chmod +s busybox
cd ..

#libraries dependencies for busybox
#SAMY : -fetch dependencies for busybox 2,3
#       -extract dependencies binary files' names 4,5
#       -find the dependencies in the gcc toolchain path 6,7
#       -copy the dependencies to the rootfs 8,9,10,11,12
#       -remove the temporary files 13
cd rootfs
aarch64-none-linux-gnu-readelf -a bin/busybox | grep "program interpreter" >> lib_dep_output.txt
aarch64-none-linux-gnu-readelf -a bin/busybox | grep "Shared library"   >> lib_dep_output.txt
grep -o '\S*so\S*' lib_dep_output.txt | sed 's/[][]//g' | sed 's/.*\///' > lib_dep_output2.txt
cat lib_dep_output2.txt > lib_dep_output.txt && rm lib_dep_output2.txt
GCC_TOOL_CHAIN_PATH=$(aarch64-none-linux-gnu-gcc -print-sysroot)
xargs -a lib_dep_output.txt -I {} find $GCC_TOOL_CHAIN_PATH -name "{}" > lib_dep_output2.txt
for item in $(cat lib_dep_output2.txt)
do
    if   [[ $item =~ .*/lib/.* ]]; then        cp -v $item ./lib
    elif [[ $item =~ .*/lib64/.* ]]; then      cp -v $item ./lib64
    elif [[ $item =~ .*/etc/.* ]]; then        cp -v $item ./etc    
    elif [[ $item =~ .*/sbin/.* ]]; then       cp -v $item ./sbin
    elif [[ $item =~ .*/usr/bin/.* ]]; then    cp -v $item ./usr/bin
    elif [[ $item =~ .*/usr/sbin.* ]]; then    cp -v $item ./usr/sbin
    elif [[ $item =~ .*/usr/.* ]]; then        cp -v $item ./usr
    elif [[ $item =~ .*/var/.* ]]; then        cp -v $item ./var
    elif [[ $item =~ .*/usr/.* ]]; then        cp -v $item ./usr
    fi  
done
rm lib_dep_output.txt lib_dep_output2.txt

# SAMY: Make device nodes
echo "Make device nodes"
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 666 dev/console c 5 1

# SAMY: Clean and build the writer utility
echo "Clean and build the writer utility"
cd ${FINDER_APP_WD}
make clean
make CROSS_COMPILE=${CROSS_COMPILE}
echo "finished Clean and build the writer utility"


# SAMY: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cp -r conf/ ${OUTDIR}/rootfs/home
for item in finder.sh finder-test.sh autorun-qemu.sh writer
do
    cp -v ${item} ${OUTDIR}/rootfs/home
done

# SAMY: Chown the root directory
echo "Chown the root directory"
sudo chown -R root:root ${OUTDIR}/rootfs


# SAMY: Create initramfs.cpio.gz
cd ${OUTDIR}/rootfs
echo "Create initramfs.cpio.gz"
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
cd ${OUTDIR}
echo "gzip initramfs.cpio"
gzip -f initramfs.cpio

cd ${FINDER_APP_WD} 
./qemu-start-application.sh



