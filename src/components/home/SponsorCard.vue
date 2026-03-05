<script setup>
import { computed, ref, onMounted, onUnmounted } from "vue";
import { useI18n } from "vue-i18n";
import { MessageCircle, Zap, GitPullRequest, ShieldCheck, ArrowUpRight } from "lucide-vue-next";

const { t } = useI18n();

const leftEyeRef = ref(null);
const rightEyeRef = ref(null);
const leftPupil = ref({ x: 0, y: 0 });
const rightPupil = ref({ x: 0, y: 0 });

function calcOffset(el, mx, my) {
  const rect = el.getBoundingClientRect();
  const cx = rect.left + rect.width / 2;
  const cy = rect.top + rect.height / 2;
  const dx = mx - cx;
  const dy = my - cy;
  const angle = Math.atan2(dy, dx);
  const dist = Math.min(3.5, Math.hypot(dx, dy) * 0.1);
  return { x: Math.cos(angle) * dist, y: Math.sin(angle) * dist };
}

function onMouseMove(e) {
  if (leftEyeRef.value) leftPupil.value = calcOffset(leftEyeRef.value, e.clientX, e.clientY);
  if (rightEyeRef.value) rightPupil.value = calcOffset(rightEyeRef.value, e.clientX, e.clientY);
}

onMounted(() => document.addEventListener("mousemove", onMouseMove));
onUnmounted(() => document.removeEventListener("mousemove", onMouseMove));

const benefits = computed(() => [
  { icon: MessageCircle, title: t("sponsorCard.benefits.devAccess.title"), desc: t("sponsorCard.benefits.devAccess.desc") },
  { icon: Zap, title: t("sponsorCard.benefits.roadmap.title"), desc: t("sponsorCard.benefits.roadmap.desc") },
  { icon: GitPullRequest, title: t("sponsorCard.benefits.earlyBuilds.title"), desc: t("sponsorCard.benefits.earlyBuilds.desc") },
  { icon: ShieldCheck, title: t("sponsorCard.benefits.badge.title"), desc: t("sponsorCard.benefits.badge.desc") },
]);
</script>

<template>
  <div class="relative group h-full flex flex-col bg-white dark:bg-[#0A0A0A] border border-gray-200 dark:border-zinc-800 rounded-xl overflow-hidden transition-all duration-400 hover:shadow-2xl hover:shadow-black/5 dark:hover:shadow-black/40 hover:border-gray-300 dark:hover:border-zinc-600">
    <!-- Hover Accents -->
    <div class="absolute top-0 left-0 w-full h-[2px] bg-gradient-to-r from-transparent via-amber-400 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
    <div class="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAiIGhlaWdodD0iMjAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGNpcmNsZSBjeD0iMSIgY3k9IjEiIHI9IjEiIGZpbGw9InJnYmEoMTUwLCAxNTAsIDE1MCwgMC4xKSIvPjwvc3ZnPg==')] opacity-0 group-hover:opacity-100 transition-opacity duration-700 pointer-events-none [mask-image:linear-gradient(to_bottom,white,transparent)]"></div>

    <div class="relative z-10 flex flex-col h-full p-5">

      <!-- Mascot -->
      <div class="flex items-center gap-4 mb-4">
        <svg viewBox="0 0 60 64" class="w-14 h-14 shrink-0 mascot-float" xmlns="http://www.w3.org/2000/svg">
          <!-- Antenna -->
          <line x1="30" y1="14" x2="30" y2="6" stroke="#f59e0b" stroke-width="2.2" stroke-linecap="round"/>
          <circle cx="30" cy="4" r="3.5" fill="#fcd34d"/>
          <circle cx="30" cy="4" r="1.8" fill="#f59e0b"/>
          <!-- Body -->
          <ellipse cx="30" cy="39" rx="22" ry="21" fill="#f59e0b"/>
          <!-- Ear bumps -->
          <circle cx="9" cy="33" r="6.5" fill="#f59e0b"/>
          <circle cx="51" cy="33" r="6.5" fill="#f59e0b"/>
          <circle cx="9" cy="33" r="3.5" fill="#fcd34d"/>
          <circle cx="51" cy="33" r="3.5" fill="#fcd34d"/>
          <!-- Eye sockets -->
          <circle ref="leftEyeRef" cx="21" cy="36" r="9" fill="white"/>
          <circle ref="rightEyeRef" cx="39" cy="36" r="9" fill="white"/>
          <!-- Pupils -->
          <circle cx="21" cy="36" r="4.5" fill="#111827" :transform="`translate(${leftPupil.x}, ${leftPupil.y})`"/>
          <circle cx="39" cy="36" r="4.5" fill="#111827" :transform="`translate(${rightPupil.x}, ${rightPupil.y})`"/>
          <!-- Eye shine (moves subtly with pupil) -->
          <circle cx="24" cy="33" r="2" fill="white" opacity="0.9" :transform="`translate(${leftPupil.x * 0.5}, ${leftPupil.y * 0.5})`"/>
          <circle cx="42" cy="33" r="2" fill="white" opacity="0.9" :transform="`translate(${rightPupil.x * 0.5}, ${rightPupil.y * 0.5})`"/>
          <!-- Blush -->
          <circle cx="11" cy="46" r="5.5" fill="#fb923c" opacity="0.35"/>
          <circle cx="49" cy="46" r="5.5" fill="#fb923c" opacity="0.35"/>
          <!-- Smile -->
          <path d="M 22 47 Q 30 54 38 47" stroke="#92400e" stroke-width="2" fill="none" stroke-linecap="round"/>
        </svg>
        <div>
          <h3 class="text-sm font-semibold text-gray-900 dark:text-white tracking-tight group-hover:text-amber-600 dark:group-hover:text-amber-400 transition-colors">{{ t('sponsorCard.title') }}</h3>
          <div class="text-[11px] font-medium text-gray-500 dark:text-zinc-400 uppercase tracking-wider mt-1">{{ t('sponsorCard.label') }}</div>
        </div>
      </div>

      <!-- Benefits 2x2 -->
      <div class="grid grid-cols-2 gap-2">
        <div
          v-for="b in benefits"
          :key="b.title"
          class="flex items-start gap-2 p-2.5 rounded-lg bg-gray-50 dark:bg-zinc-900/50 border border-gray-100 dark:border-zinc-800/50"
        >
          <component :is="b.icon" class="w-3.5 h-3.5 text-amber-500 shrink-0 mt-0.5" />
          <div class="flex flex-col">
            <span class="text-[11px] font-semibold text-gray-900 dark:text-white">{{ b.title }}</span>
            <span class="text-[10px] text-gray-500 dark:text-zinc-400 leading-snug mt-0.5">{{ b.desc }}</span>
          </div>
        </div>
      </div>

      <!-- CTA -->
      <div class="mt-3 pt-3 border-t border-gray-100 dark:border-zinc-800/80">
        <a
          href="https://sponsor.besoeasy.com/"
          target="_blank"
          rel="noopener noreferrer"
          class="group/cta flex items-center justify-between w-full px-4 py-3 rounded-lg bg-gray-950 dark:bg-white text-white dark:text-gray-950 transition-all duration-300 hover:bg-gray-800 dark:hover:bg-gray-100 active:scale-[0.98]"
        >
          <span class="text-xs font-bold tracking-tight">{{ t('sponsorCard.cta') }}</span>
          <ArrowUpRight class="w-4 h-4 opacity-50 transition-all duration-300 group-hover/cta:opacity-100 group-hover/cta:translate-x-0.5 group-hover/cta:-translate-y-0.5" />
        </a>
      </div>
    </div>
  </div>
</template>

<style scoped>
.mascot-float {
  animation: mascotFloat 3.5s ease-in-out infinite;
}

@keyframes mascotFloat {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-5px); }
}
</style>
