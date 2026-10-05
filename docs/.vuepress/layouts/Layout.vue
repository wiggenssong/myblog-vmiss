<script setup>
import { Layout } from 'vuepress-theme-plume/client'
</script>

<template>
  <Layout>
    <template #page-bottom>
      <div class="busuanzi-counter">
        <span>本站总访问量 <span id="busuanzi_value_site_pv" class="busuanzi-value" /> 次</span>
        <span class="busuanzi-divider">·</span>
        <span>本站访客数 <span id="busuanzi_value_site_uv" class="busuanzi-value" /> 人次</span>
      </div>
    </template>
  </Layout>
</template>

<style>
.busuanzi-counter {
  width: 100%;
  text-align: center;
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
  padding: 0.5rem 0 1rem;
}
.busuanzi-divider {
  margin: 0 0.6rem;
  opacity: 0.5;
}
</style>
