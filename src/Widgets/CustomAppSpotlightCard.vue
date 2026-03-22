<script setup>
import { ref, computed, onMounted, defineOptions } from "vue";
import { useRouter } from "vue-router";
defineOptions({ colSpan: 2 });
import { useI18n } from "vue-i18n";
import { ArrowRight, Bot, Wrench } from "lucide-vue-next";
import { useApiUrl } from "../composables/useApiUrl";

const { t } = useI18n();
const router = useRouter();
const { apiUrl } = useApiUrl();

const apps = ref([]);
const containers = ref([]);

function getDateDaySeed() {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, "0");
  const day = String(now.getDate()).padStart(2, "0");
  // Offset by 1 so this card picks a different app than DailyAppSpotlightCard on the same day
  return `custom-${year}-${month}-${day}`;
}

function hashString(value) {
  let hash = 0;
  for (let i = 0; i < value.length; i++) {
    hash = (hash * 31 + value.charCodeAt(i)) >>> 0;
  }
  return hash;
}

const installedAppIds = computed(() => new Set(containers.value.map((c) => c?.app?.id).filter(Boolean)));

const runningAppInstanceCounts = computed(() => {
  const projectsByApp = {};
  containers.value
    .filter((c) => c.state === "running")
    .forEach((c) => {
      const appId = c?.app?.id;
      const projectId = c?.app?.projectId;
      if (!appId || !projectId) return;
      if (!projectsByApp[appId]) projectsByApp[appId] = new Set();
      projectsByApp[appId].add(projectId);
    });
  const counts = {};
  for (const [appId, projects] of Object.entries(projectsByApp)) counts[appId] = projects.size;
  return counts;
});

const dailyApp = computed(() => {
  const custom = apps.value.filter((a) => a.customapp);
  if (custom.length === 0) return null;
  const catalog = [...custom].sort((a, b) => a.id.localeCompare(b.id));
  const index = hashString(getDateDaySeed()) % catalog.length;
  const featured = catalog[index];
  return {
    ...featured,
    isInstalled: installedAppIds.value.has(featured.id),
    instanceCount: runningAppInstanceCounts.value[featured.id] || 0,
  };
});

async function fetchData() {
  try {
    const [appsRes, containersRes] = await Promise.all([
      fetch(`${apiUrl.value}/api/apps`),
      fetch(`${apiUrl.value}/api/containers`),
    ]);
    const appsData = await appsRes.json();
    const containersData = await containersRes.json();
    if (appsData.success) apps.value = Array.isArray(appsData.apps) ? appsData.apps : [];
    if (containersData.success) containers.value = containersData.containers;
  } catch {}
}

function handleSelect() {
  if (!dailyApp.value?.id) return;
  if ((dailyApp.value.instanceCount || 0) > 0) {
    router.push(`/app/${dailyApp.value.id}`);
  } else {
    router.push(`/apps/${dailyApp.value.id}`);
  }
}

onMounted(fetchData);

const instanceCount = computed(() => dailyApp.value?.instanceCount ?? 0);

const appState = computed(() => {
  if (instanceCount.value > 0) return "running";
  if (dailyApp.value?.isInstalled) return "installed";
  return "available";
});

const primaryTag = computed(() => {
  const tags = dailyApp.value?.tags;
  if (!Array.isArray(tags) || tags.length === 0) return null;
  return tags[0];
});

const actionLabel = computed(() => {
  if (appState.value === "running") return t("home.dailyAppCard.openOverview");
  return t("home.dailyAppCard.viewApp");
});

const stateLabel = computed(() => {
  if (appState.value === "running") return t("home.dailyAppCard.running", { count: instanceCount.value });
  if (appState.value === "installed") return t("home.dailyAppCard.installed");
  return t("home.dailyAppCard.available");
});
</script>

<template>
  <button
    v-if="dailyApp"
    type="button"
    @click="handleSelect"
    class="relative group h-full w-full overflow-hidden rounded-xl bg-[var(--surface)] text-left transition-all duration-300 hover:-translate-y-0.5 smooth-shadow hover:smooth-shadow-lg"
  >
    <div class="flex h-full min-h-[9rem]">
      <!-- Left accent panel: icon + name -->
      <div class="flex w-[38%] shrink-0 flex-col items-center justify-center gap-3 bg-[var(--surface-muted)] px-4 py-6 rounded-l-xl">
        <div class="flex h-14 w-14 items-center justify-center rounded-2xl bg-[var(--surface)] p-3">
          <img
            v-if="dailyApp?.logo"
            :src="dailyApp.logo"
            :alt="dailyApp.name"
            class="h-full w-full object-contain"
            loading="lazy"
          />
          <Bot v-else class="h-6 w-6 text-[var(--text-secondary)]" />
        </div>
        <p class="text-center text-sm font-semibold leading-tight text-[var(--text-primary)]">{{ dailyApp?.name }}</p>
        <div class="inline-flex items-center gap-1.5">
          <span
            :class="[
              'h-1.5 w-1.5 rounded-full',
              appState === 'running' ? 'bg-emerald-500' : appState === 'installed' ? 'bg-blue-500' : 'bg-gray-400 dark:bg-zinc-500'
            ]"
          ></span>
          <span class="text-[10px] font-bold uppercase tracking-wider text-[var(--text-secondary)]">{{ stateLabel }}</span>
        </div>
      </div>

      <!-- Right content panel -->
      <div class="flex flex-1 flex-col justify-between p-5">
        <div>
          <div class="mb-2 flex items-center gap-1.5 text-[10px] font-bold uppercase tracking-[0.18em] text-[var(--text-secondary)]">
            <Wrench class="h-3 w-3" />
            <span>Custom App · Daily Pick</span>
          </div>
          <p class="text-sm leading-relaxed text-[var(--text-secondary)] line-clamp-3">
            {{ dailyApp?.short_description || dailyApp?.description || t("home.dailyAppCard.noDescription") }}
          </p>
        </div>

        <div class="mt-3 flex items-center justify-between gap-2">
          <div v-if="primaryTag" class="inline-flex items-center gap-1.5 rounded-md bg-[var(--surface-muted)] px-2.5 py-1">
            <span class="text-[11px] font-semibold uppercase tracking-wider text-[var(--text-secondary)]">{{ primaryTag }}</span>
          </div>
          <div class="ml-auto flex items-center gap-2 text-[var(--text-secondary)] transition-all group-hover:text-[var(--text-primary)]">
            <span class="text-xs font-medium">{{ actionLabel }}</span>
            <ArrowRight class="h-3.5 w-3.5 transition-transform group-hover:translate-x-0.5" />
          </div>
        </div>
      </div>
    </div>
  </button>
</template>
