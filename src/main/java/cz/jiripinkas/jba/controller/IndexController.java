package cz.jiripinkas.jba.controller;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import cz.jiripinkas.jba.dto.ItemDto;
import cz.jiripinkas.jba.service.BlogService;
import cz.jiripinkas.jba.service.ItemService;
import cz.jiripinkas.jba.service.UserService;
import cz.jiripinkas.jba.service.ItemService.MaxType;
import cz.jiripinkas.jba.service.ItemService.OrderType;

@Controller
public class IndexController {

	@Autowired
	private ItemService itemService;

	@Autowired
	private UserService userService;

	@Autowired
	private BlogService blogService;

	private String showFirstPage(Model model, HttpServletRequest request, String tilesPage, OrderType orderType, MaxType maxType) {
		model.addAttribute("lastIndexDate", blogService.getLastIndexDateMinutes());
		model.addAttribute("blogCount", blogService.count());
		if (request.isUserInRole("ROLE_ADMIN")) {
			model.addAttribute("itemCount", itemService.count());
			model.addAttribute("userCount", userService.count());
		}
		return showPage(model, request, 0, tilesPage, orderType, maxType);
	}

	private String showPage(Model model, HttpServletRequest request, int page, String tilesPage, OrderType orderType, MaxType maxType) {
		boolean showAll = false;
		if (request.isUserInRole("ROLE_ADMIN")) {
			showAll = true;
		}
		model.addAttribute("items", itemService.getDtoItems(page, showAll, orderType, maxType));
		model.addAttribute("nextPage", page + 1);
		return tilesPage;
	}

	@RequestMapping("/index")
	public String index(Model model, HttpServletRequest request) {
		model.addAttribute("title", "Latest news from the Java world:");
		return showFirstPage(model, request, "index", OrderType.LATEST, MaxType.UNDEFINED);
	}

	@RequestMapping(value = "/index", params = "page")
	public String index(Model model, @RequestParam int page, HttpServletRequest request) {
		model.addAttribute("title", "Latest news from the Java world:");
		return showPage(model, request, page, "index", OrderType.LATEST, MaxType.UNDEFINED);
	}

	private MaxType resolveMaxType(String max) {
		MaxType maxType = MaxType.UNDEFINED;
		if ("month".equals(max)) {
			maxType = MaxType.MONTH;
		} else if ("week".equals(max)) {
			maxType = MaxType.WEEK;
		}
		return maxType;
	}

	private String resolveTitle(MaxType maxType) {
		String finalTitle = "Best Java news";
		switch (maxType) {
		case MONTH:
			finalTitle += " this month: ";
			break;
		case WEEK:
			finalTitle += " this week: ";
			break;
		default:
			finalTitle += ": ";
			break;
		}
		return finalTitle;
	}

	private MaxType populateModelWithMax(Model model, String max) {
		model.addAttribute("topViews", true);
		MaxType maxType = resolveMaxType(max);
		if (maxType != MaxType.UNDEFINED) {
			model.addAttribute("max", true);
			model.addAttribute("maxValue", max);
		}
		model.addAttribute("title", resolveTitle(maxType));
		return maxType;
	}

	@RequestMapping(value = "/index", params = "top-views")
	public String topViews(Model model, HttpServletRequest request, @RequestParam(required = false) String max) {
		MaxType maxType = populateModelWithMax(model, max);
		return showFirstPage(model, request, "top-views", OrderType.MOST_VIEWED, maxType);
	}

	@RequestMapping(value = "/index", params = { "page", "top-views" })
	public String topViews(Model model, @RequestParam int page, HttpServletRequest request, @RequestParam(required = false) String max) {
		MaxType maxType = populateModelWithMax(model, max);
		return showPage(model, request, page, "top-views", OrderType.MOST_VIEWED, maxType);
	}

	@ResponseBody
	@RequestMapping("/page/{page}")
	public List<ItemDto> getPageLatest(@PathVariable int page, HttpServletRequest request) {
		boolean showAll = false;
		if (request.isUserInRole("ROLE_ADMIN")) {
			showAll = true;
		}
		return itemService.getDtoItems(page, showAll, OrderType.LATEST, MaxType.UNDEFINED);
	}

	@ResponseBody
	@RequestMapping(value = "/page/{page}", params = "topviews")
	public List<ItemDto> getPageMostViewed(@PathVariable int page, HttpServletRequest request, @RequestParam(required = false) String max) {
		boolean showAll = false;
		if (request.isUserInRole("ROLE_ADMIN")) {
			showAll = true;
		}
		return itemService.getDtoItems(page, showAll, OrderType.MOST_VIEWED, resolveMaxType(max));
	}

	@ResponseBody
	@RequestMapping(value = "/inc-count", method = RequestMethod.POST)
	public String incItemCount(@RequestParam int itemId) {
		return Integer.toString(itemService.incCount(itemId));
	}
}
