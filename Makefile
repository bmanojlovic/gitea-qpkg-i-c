all: giteabin sugo-bin

# su-exec compile does not work for x86 and x86_64 as cross compilers are broken so do not bother...
#su-exec-bin

giteabin:
	curl -# -Ro Gitea/arm-x19/bin/gitea https://dl.gitea.io/gitea/master/gitea-master-linux-arm-5
	curl -# -Ro Gitea/x86_64/bin/gitea https://dl.gitea.io/gitea/master/gitea-master-linux-amd64
	curl -# -Ro Gitea/x86/bin/gitea https://dl.gitea.io/gitea/master/gitea-master-linux-386

su-exec-bin:
	git clone https://github.com/ncopa/su-exec || true
	( cd su-exec; docker run -v `pwd`:/tmp/src --rm -ti cross-qnap-i-c:x86 gcc -o su-exec-x86 su-exec.c || true )
	# x86_64 until i get real cross compiler running is broken..
	( cd su-exec; gcc -o su-exec-amd64 su-exec.c || true )
	( cd su-exec; docker run -v `pwd`:/tmp/src --rm -ti cross-qnap-i-c:arm gcc -o su-exec-arm su-exec.c || true )
	cp su-exec/su-exec-arm Gitea/arm-x19/bin/su-exec

sugo-bin:
	mkdir -p Gitea/arm-x19/bin Gitea/x86_64/bin Gitea/x86/bin
	wget -O Gitea/arm-x19/bin/su-exec https://github.com/tianon/gosu/releases/download/1.10/gosu-armel
	wget -O Gitea/x86_64/bin/su-exec https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64
	wget -O Gitea/x86/bin/su-exec https://github.com/tianon/gosu/releases/download/1.10/gosu-i386
	chmod 755 Gitea/*/bin/su-exec

clean:
	rm -f Gitea/arm-x19/bin/gitea Gitea/arm-x19/bin/su-exec
	rm -f Gitea/x86_64/bin/gitea Gitea/x86_64/bin/su-exec
	rm -f Gitea/x86/bin/gitea Gitea/x86/bin/su-exec

qpkg-bin:
	docker run -v `pwd`:/wd qdk2 bash -c "cd /wd/Gitea && /usr/share/qdk2/bin/qbuild -v"