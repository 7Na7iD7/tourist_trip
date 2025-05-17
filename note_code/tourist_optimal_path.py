import random
import time
from rich import print
from rich.console import Console
from rich.table import Table
from rich.progress import track, Progress

console = Console()


class TouristPlanner:
    def __init__(self):
        self.places = []
        self.place_names = {}
        self.visit_times = {}
        self.distances = {}
        self.optimal_tour = []
        self.optimal_time = 0

    def generate_fixed_data(self):
        self.places = ['A', 'B', 'C', 'D', 'E']
        self.place_names = {
            'A': 'موزه ملی 🎨',
            'B': 'پارک آب و آتش 🌊',
            'C': 'برج میلاد 🗼',
            'D': 'دریاچه چیتگر 🌅',
            'E': 'پل طبیعت 🌉',
        }
        self.visit_times = {
            'A': 60,
            'B': 40,
            'C': 80,
            'D': 60,
            'E': 30,
        }
        self.distances = {
            'A': {'A': 0, 'B': 10, 'C': 25, 'D': 50, 'E': 15},
            'B': {'A': 10, 'B': 0, 'C': 20, 'D': 40, 'E': 5},
            'C': {'A': 25, 'B': 20, 'C': 0, 'D': 30, 'E': 15},
            'D': {'A': 50, 'B': 40, 'C': 30, 'D': 0, 'E': 35},
            'E': {'A': 15, 'B': 5, 'C': 15, 'D': 35, 'E': 0},
        }
        self.apply_floyd_warshall()

    def apply_floyd_warshall(self):
        for k in self.places:
            for i in self.places:
                for j in self.places:
                    if self.distances[i][j] > self.distances[i][k] + self.distances[k][j]:
                        self.distances[i][j] = self.distances[i][k] + self.distances[k][j]

    def calculate_optimal_tour(self, time_limit=180):
        for step in track(range(10), description="محاسبه مسیر..."):
            time.sleep(0.05)

        n = len(self.places)
        dp = [[float('inf')] * (1 << n) for _ in range(n)]
        parent = [[None] * (1 << n) for _ in range(n)]

        best_tour = []
        best_time = time_limit + 1
        best_count = 0

        for start_idx in range(n):
            start_mask = 1 << start_idx
            dp[start_idx][start_mask] = self.visit_times[self.places[start_idx]]

            for mask in range(1, 1 << n):
                for curr in range(n):
                    if dp[curr][mask] == float('inf'):
                        continue
                    for nxt in range(n):
                        if mask & (1 << nxt):
                            continue
                        new_mask = mask | (1 << nxt)
                        travel = self.distances[self.places[curr]][self.places[nxt]]
                        visit = self.visit_times[self.places[nxt]]
                        total = dp[curr][mask] + travel + visit

                        if total <= time_limit and total < dp[nxt][new_mask]:
                            dp[nxt][new_mask] = total
                            parent[nxt][new_mask] = (curr, mask)

            for mask in range(1, 1 << n):
                for end in range(n):
                    if dp[end][mask] <= time_limit:
                        visited = bin(mask).count("1")
                        if visited > best_count or (visited == best_count and dp[end][mask] < best_time):
                            best_time = dp[end][mask]
                            best_end = end
                            best_mask = mask
                            best_count = visited

        self.optimal_tour = []
        if best_count == 0:
            return

        curr, mask = best_end, best_mask
        while mask:
            self.optimal_tour.append(self.places[curr])
            prev = parent[curr][mask]
            if not prev:
                break
            curr, mask = prev
        self.optimal_tour.reverse()
        self.optimal_time = best_time

    def show_result(self, time_limit):
        table = Table(title="📍 جدول مکان‌های گردشگری", show_lines=True)
        table.add_column("کد", justify="center")
        table.add_column("نام", justify="center")
        table.add_column("⏱️ زمان بازدید", justify="center")

        for p in self.places:
            table.add_row(p, self.place_names.get(p, p), f"{self.visit_times[p]} دقیقه")
        console.print(table)

        print(f"\n[bold green]🧭 مسیر بهینه:[/bold green] {' ➡️ '.join(self.optimal_tour)}")
        print(f"[cyan]📌 تعداد مکان‌های بازدید شده:[/] {len(self.optimal_tour)} مکان")

        percent = (self.optimal_time / time_limit) * 100
        if percent <= 70:
            color = "green"
        elif percent <= 90:
            color = "yellow"
        else:
            color = "red"
        print(f"[{color}]⏱️ مجموع زمان:[/] {self.optimal_time} دقیقه ({percent:.1f}% از زمان مجاز)")

        with Progress() as progress:
            task = progress.add_task("⏳ پیشرفت سفر:", total=time_limit)
            progress.update(task, completed=self.optimal_time)

        print("\n📋 [bold]جزئیات کامل مسیر:[/bold]")
        total = 0
        for i, place in enumerate(self.optimal_tour):
            name = self.place_names[place]
            visit = self.visit_times[place]
            if i == 0:
                print(f"🚶‍♂️ شروع از {place} ({name})")
                print(f"    ⏱️ بازدید: {visit} دقیقه")
                total += visit
            else:
                prev = self.optimal_tour[i - 1]
                travel = self.distances[prev][place]
                print(f"➡️ حرکت به {place} ({name})")
                print(f"    🚗 زمان سفر: {travel} دقیقه")
                print(f"    ⏱️ بازدید: {visit} دقیقه")
                total += travel + visit
        print(f"📈 کل زمان سپری شده: {total} دقیقه")

        return total

    def save_to_file(self, filename="result.txt"):
        with open(filename, "w", encoding="utf-8") as f:
            f.write("🧭 مسیر بهینه:\n")
            for p in self.optimal_tour:
                f.write(f"{p} ({self.place_names[p]})\n")
            f.write(f"\n📌 تعداد مکان‌ها: {len(self.optimal_tour)}\n")
            f.write(f"⏱️ مجموع زمان: {self.optimal_time} دقیقه\n")


def main():
    print("[bold magenta]\n🗺️ [underline]برنامه‌ی محاسبه مسیر بهینه بین مکان‌های گردشگری[/underline][/bold magenta]")
    print(
        "[cyan]📌 این برنامه از الگوریتم [bold]فلوید-وارشال[/bold] و [bold]برنامه‌ریزی پویا[/bold] استفاده می‌کند.[/cyan]\n")
    print("[bold yellow]🔧 حالت را انتخاب کن:[/] [green]1. ثابت[/green] / [blue]2. تصادفی[/blue]")

    mode = input("حالت (1 یا 2): ").strip()
    planner = TouristPlanner()

    if mode == "1":
        planner.generate_fixed_data()
    else:
        count = int(input("چند مکان گردشگری تولید شود؟ (2 تا 10): "))
        count = max(2, min(count, 10))
        planner.places = [chr(65 + i) for i in range(count)]
        names = ['موزه', 'پارک', 'بازار', 'کاخ', 'مرکز خرید', 'دریاچه', 'رصدخانه', 'آبشار', 'آکواریوم', 'برج']
        planner.place_names = {p: f"{names[i % len(names)]} {p}" for i, p in enumerate(planner.places)}
        planner.visit_times = {p: random.randint(10, 50) for p in planner.places}
        planner.distances = {
            p1: {p2: (0 if p1 == p2 else random.randint(10, 100)) for p2 in planner.places}
            for p1 in planner.places
        }
        planner.apply_floyd_warshall()

    time_limit = int(input("✅ محدودیت زمانی سفر را وارد کن (مثلاً 180): "))
    planner.calculate_optimal_tour(time_limit)
    planner.show_result(time_limit)

    save = input("📄 خروجی در فایل ذخیره شود؟ (y/n): ").strip().lower()
    if save == "y":
        planner.save_to_file()
        print("[bold green]✅ خروجی در فایل result.txt ذخیره شد.[/bold green]")


if __name__ == "__main__":
    main()
