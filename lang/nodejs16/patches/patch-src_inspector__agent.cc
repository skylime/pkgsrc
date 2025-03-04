$NetBSD: patch-src_inspector__agent.cc,v 1.2 2022/08/29 06:28:38 adam Exp $

--- src/inspector_agent.cc.orig	2022-08-16 06:43:18.000000000 +0000
+++ src/inspector_agent.cc
@@ -96,7 +96,7 @@ static int StartDebugSignalHandler() {
   CHECK_EQ(0, uv_sem_init(&start_io_thread_semaphore, 0));
   pthread_attr_t attr;
   CHECK_EQ(0, pthread_attr_init(&attr));
-#if defined(PTHREAD_STACK_MIN) && !defined(__FreeBSD__)
+#if defined(PTHREAD_STACK_MIN) && !defined(__FreeBSD__) && !defined(__NetBSD__)
   // PTHREAD_STACK_MIN is 2 KiB with musl libc, which is too small to safely
   // receive signals. PTHREAD_STACK_MIN + MINSIGSTKSZ is 8 KiB on arm64, which
   // is the musl architecture with the biggest MINSIGSTKSZ so let's use that
